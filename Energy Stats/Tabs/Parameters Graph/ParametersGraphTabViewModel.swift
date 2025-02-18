//
//  GraphTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import Foundation
import SwiftUI

struct ValuesAtTime<T> {
    let values: [T]
}

struct ParametersGraphDisplayMode: Equatable {
    let date: Date
    let hours: Int

    static func ==(lhs: ParametersGraphDisplayMode, rhs: ParametersGraphDisplayMode) -> Bool {
        lhs.hours == rhs.hours &&
            lhs.date.iso8601() == rhs.date.iso8601()
    }
}

struct ParametersGraphViewData {
    let values: [ParameterGraphValue]
    let yScale: ClosedRange<Double>

    static func empty() -> ParametersGraphViewData {
        ParametersGraphViewData(values: [], yScale: 0...0)
    }
}

class ParametersGraphTabViewModel: ObservableObject, HasLoadState, VisibilityTracking {
    private let haptic = UIImpactFeedbackGenerator()
    private let networking: Networking
    private var configManager: ConfigManaging
    private var rawData: [ParameterGraphValue] = [] {
        didSet {
            assignData(from: rawData)
        }
    }

    private let dateProvider: () -> Date
    @Published var state = LoadState.inactive
    var visible: Bool = false
    var lastLoadState: LastLoadState<ParametersGraphLoadState>?

    @Published private(set) var stride = 3
    @Published private(set) var data: [String: ParametersGraphViewData] = [:]
    @Published var graphVariables: [ParameterGraphVariable] = []
    @Published var graphVariableBounds: [ParameterGraphBounds] = []
    private var queryDate = QueryDate.now()
    private var hours: Int = 24
    private var max: ParameterGraphValue?
    var exportFile: CSVTextFile?
    @Published var xScale: ClosedRange<Date> = Calendar.current.startOfDay(for: Date())...Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
    @Published var hasLoaded: Bool = false
    private var loadTask: Task<Void, Never>?
    private let solarForecastProvider: SolarForecastProviding

    @Published var displayMode: ParametersGraphDisplayMode {
        didSet {
            let previousHours = hours

            let updatedDate = QueryDate(from: displayMode.date)
            if queryDate != updatedDate {
                queryDate = updatedDate
                performLoad()
            }
            if displayMode.hours != previousHours {
                hours = displayMode.hours

                switch hours {
                case 6:
                    stride = 1
                case 12:
                    stride = 2
                default:
                    stride = 3
                }

                refresh()
            }
        }
    }

    private var cancellable: AnyCancellable?

    init(
        networking: Networking,
        configManager: ConfigManaging,
        dateProvider: @escaping () -> Date = { Date() },
        solarForecastProvider: @escaping SolarForecastProviding
    ) {
        self.networking = networking
        self.configManager = configManager
        self.dateProvider = dateProvider
        self.solarForecastProvider = solarForecastProvider
        displayMode = ParametersGraphDisplayMode(date: dateProvider(), hours: 24)
        haptic.prepare()

        cancellable = configManager.currentDevice
            .map { [weak self] _ in
                guard let self else { return [] }

                let configVariables = configManager.variables.compactMap { [weak self] variable -> ParameterGraphVariable? in
                    guard let self else { return nil }

                    return ParameterGraphVariable(variable,
                                                  isSelected: selectedGraphVariables.contains(variable.variable),
                                                  enabled: selectedGraphVariables.contains(variable.variable))
                }

                let solarGraphVariable = [ParameterGraphVariable(
                    Variable.solcastPredictionVariable,
                    isSelected: selectedGraphVariables.contains(Variable.solcastPredictionVariable.variable)
                )]

                return configVariables + solarGraphVariable
            }
            .receive(on: RunLoop.main)
            .assign(to: \.graphVariables, on: self)

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc
    func didBecomeActiveNotification() {
        if hasData, visible {
            performLoad()
        }
    }

    private var hasData: Bool {
        data.isEmpty == false
    }

    var selectedGraphVariables: [String] {
        if configManager.selectedParameterGraphVariables.count == 0 {
            return ParameterGraphVariableChooserViewModel.DefaultGraphVariables
        } else {
            return configManager.selectedParameterGraphVariables
        }
    }

    private func performLoad() {
        loadTask?.cancel()
        loadTask = Task { await self.load() }
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }
        guard let start = queryDate.asDate() else { return }
        guard requiresLoad() else { return }

        await setState(.active("Loading"))

        do {
            let rawGraphVariables = graphVariables
                .filter { $0.isSelected }
                .filter { $0.type.variable != Variable.solcastPredictionVariable.variable }
                .compactMap { $0.type }
            let startDate = Calendar.current.startOfDay(for: start)
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
            let raw = try await networking.fetchHistory(deviceSN: currentDevice.deviceSN, variables: rawGraphVariables.map { $0.variable }, start: startDate, end: endDate)
            let rawData: [ParameterGraphValue] = raw.datas.flatMap { response -> [ParameterGraphValue] in
                guard let rawVariable = configManager.variables.first(where: { $0.variable == response.variable }) else { return [] }

                return response.data.compactMap {
                    ParameterGraphValue(date: $0.time, value: $0.value, variable: rawVariable)
                }
            }
            let solarData = selectedGraphVariables.contains(Variable.solcastPredictionVariable.variable) ? await fetchSolarForecasts() : []

            if Task.isCancelled { return }

            await MainActor.run {
                self.rawData = rawData + solarData
                self.refresh()
                prepareExport()
                Task {
                    await setState(.inactive)
                }
                self.lastLoadState = LastLoadState(lastLoadTime: .now, loadState: ParametersGraphLoadState(displayMode: displayMode, variables: graphVariables))
                self.hasLoaded = true
            }
        } catch {
            await setState(.error(error, "Could not load, check your connection"))
        }
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type }

        let refreshedData = rawData
            .filter { !hiddenVariableTypes.contains($0.type) }
            .filter { value in
                let hours = displayMode.hours
                let oldest = displayMode.date.addingTimeInterval(0 - (3600 * Double(hours)))
                return value.date > oldest
            }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })

        max = refreshedData.max(by: { lhs, rhs in
            lhs.value < rhs.value
        })

        graphVariableBounds = graphVariables.map { variable in
            let variableData = refreshedData.filter { $0.type == variable.type }

            let min = variableData.min(by: { lhs, rhs in
                lhs.value < rhs.value
            })?.value
            let max = variableData.max(by: { lhs, rhs in
                lhs.value < rhs.value
            })?.value
            let now = variableData.last?.value

            return ParameterGraphBounds(type: variable.type, min: min, max: max, now: now)
        }

        let start = Swift.max(displayMode.date.addingTimeInterval(0 - (3600 * Double(hours))), Calendar.current.startOfDay(for: displayMode.date))
        if displayMode.hours < 24 {
            xScale = start...displayMode.date
        } else {
            xScale = start...Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: displayMode.date))!
        }

        assignData(from: refreshedData)

        storeVariables()
    }

    func data(at date: Date) -> ValuesAtTime<ParameterGraphValue> {
        let visibleVariableTypes = graphVariables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.type) })

        if let maxDate = max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        return result
    }

    func toggle(visibilityOf variable: ParameterGraphVariable) {
        graphVariables = graphVariables.map {
            if $0.type == variable.type {
                var modified = $0
                modified.enabled.toggle()
                return modified
            } else {
                return $0
            }
        }
    }

    func set(graphVariables: [ParameterGraphVariable]) {
        self.graphVariables = graphVariables
        performLoad()
    }

    var axisType: AxisUnit = .consistent("kW")

    func prepareExport() {
        let headers = ["Type", "Date", "Value"].lazy.joined(separator: ",")
        let rows = rawData.map {
            [$0.type.name, $0.date.iso8601(), String(describing: $0.value)].lazy.joined(separator: ",")
        }

        let text = ([headers] + rows).joined(separator: "\n")

        let exportFileName: String
        let date = displayMode.date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        if let year = components.year, let day = components.day {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            let monthName = dateFormatter.string(from: date)
            exportFileName = "energystats_parameters_\(year)_\(monthName)_\(day).csv"
        } else {
            exportFileName = "energystats_parameters_unknown_date.csv"
        }

        exportFile = CSVTextFile(text: text, filename: exportFileName)
    }

    private func storeVariables() {
        configManager.selectedParameterGraphVariables = graphVariables.filter { $0.isSelected }.map { $0.type.variable }
    }

    private func assignData(from grouped: [ParameterGraphValue]) {
        let rawGrouped = Dictionary(grouping: grouped, by: { $0.type.unit })
        var updated = [String: ParametersGraphViewData]()
        for item in rawGrouped {
            updated[item.key] = ParametersGraphViewData(values: item.value, yScale: 1...3)
        }
        data = updated
    }
}

extension ParametersGraphTabViewModel: LoadTracking {
    func requiresLoad() -> Bool {
        guard let lastLoadState else { return true }

        let sufficientTimeHasPassed = lastLoadState.lastLoadTime.timeIntervalSinceNow > (5 * 60)
        let viewDataHasChanged = lastLoadState.loadState.displayMode != displayMode ||
            lastLoadState.loadState.variables != graphVariables

        return sufficientTimeHasPassed || viewDataHasChanged
    }
}

// Solar
extension ParametersGraphTabViewModel {
    func fetchSolarForecasts() async -> [ParameterGraphValue] {
        guard let apiKey = configManager.solcastSettings.apiKey else { return [] }
        guard let requestedDate = queryDate.asDate() else { return [] }
        let today = Calendar.current.startOfDay(for: requestedDate)
        let service = solarForecastProvider()

        do {
            let data = try await configManager.solcastSettings.sites.asyncMap { site in
                let data = try await service.fetchForecast(for: site, apiKey: apiKey, ignoreCache: false)
                let todayData = data.forecasts.filter { $0.periodEnd.isSame(as: today) }

                return todayData
            }.flatMap { $0 }

            let groupedForecasts = aggregateAndIntegrateForecasts(data)

            return groupedForecasts.map { solcastResponse in
                ParameterGraphValue(
                    date: solcastResponse.periodEnd,
                    value: solcastResponse.pvEstimate,
                    variable: Variable.solcastPredictionVariable
                )
            }.sorted(by: { $0.date < $1.date })
        } catch {
            return []
        }
    }

    func aggregateAndIntegrateForecasts(_ forecasts: [SolcastForecastResponse]) -> [SolcastForecastResponse] {
        let calendar = Calendar.current

        // Step 1: Sum duplicate periodEnds
        let summedForecasts = Dictionary(grouping: forecasts, by: { $0.periodEnd })
            .map { periodEnd, entries in
                SolcastForecastResponse(
                    pvEstimate: entries.reduce(0) { $0 + $1.pvEstimate },
                    pvEstimate10: entries.reduce(0) { $0 + $1.pvEstimate10 },
                    pvEstimate90: entries.reduce(0) { $0 + $1.pvEstimate90 },
                    periodEnd: periodEnd,
                    period: entries.first?.period ?? ""
                )
            }

        // Step 2: Group by hour
        let hourlyGrouped = Dictionary(grouping: summedForecasts) { forecast in
            calendar.date(bySetting: .minute, value: 0, of: forecast.periodEnd)!
        }

        // Step 3: Perform Riemann sum integration for each hour
        return hourlyGrouped.map { periodStart, forecastsInHour in
            let sorted = forecastsInHour.sorted(by: { $0.periodEnd < $1.periodEnd })

            var totalPvEstimate: Double = 0
            var totalPvEstimate10: Double = 0
            var totalPvEstimate90: Double = 0

            for i in 0 ..< sorted.count - 1 {
                let left = sorted[i]
                let right = sorted[i + 1]

                let timeDiff = right.periodEnd.timeIntervalSince(left.periodEnd) / 3600.0 // Convert to hours

                // Trapezoidal Riemann sum integration
                totalPvEstimate += 0.5 * timeDiff * (left.pvEstimate + right.pvEstimate)
                totalPvEstimate10 += 0.5 * timeDiff * (left.pvEstimate10 + right.pvEstimate10)
                totalPvEstimate90 += 0.5 * timeDiff * (left.pvEstimate90 + right.pvEstimate90)
            }

            return SolcastForecastResponse(
                pvEstimate: totalPvEstimate,
                pvEstimate10: totalPvEstimate10,
                pvEstimate90: totalPvEstimate90,
                periodEnd: periodStart, // Use the start of the hour as reference
                period: "1h"
            )
        }.sorted(by: { $0.periodEnd < $1.periodEnd }) // Ensure chronological order
    }
}

enum AxisUnit {
    case mixed
    case consistent(String)
}

struct ParametersGraphLoadState {
    let displayMode: ParametersGraphDisplayMode
    let variables: [ParameterGraphVariable]
}
