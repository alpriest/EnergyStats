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

    @Published var displayMode: ParametersGraphDisplayMode {
        didSet {
            let previousHours = hours

            let updatedDate = QueryDate(from: displayMode.date)
            if queryDate != updatedDate {
                queryDate = updatedDate
                Task { @MainActor in
                    await load()
                }
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

    init(networking: Networking, configManager: ConfigManaging, dateProvider: @escaping () -> Date = { Date() }) {
        self.networking = networking
        self.configManager = configManager
        self.dateProvider = dateProvider
        displayMode = ParametersGraphDisplayMode(date: dateProvider(), hours: 24)
        haptic.prepare()

        cancellable = configManager.currentDevice
            .map { [weak self] _ in
                guard let self else { return [] }

                return configManager.variables.compactMap { [weak self] variable -> ParameterGraphVariable? in
                    guard let self else { return nil }

                    return ParameterGraphVariable(variable,
                                                  isSelected: selectedGraphVariables.contains(variable.variable),
                                                  enabled: selectedGraphVariables.contains(variable.variable))
                }
            }
            .receive(on: RunLoop.main)
            .assign(to: \.graphVariables, on: self)

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc
    func didBecomeActiveNotification() {
        if hasData, visible {
            Task { await self.load() }
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

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }
        guard let start = queryDate.asDate() else { return }
        guard requiresLoad() else { return }

        setState(.active("Loading"))

        do {
            let rawGraphVariables = graphVariables.filter { $0.isSelected }.compactMap { $0.type }
            let startDate = Calendar.current.startOfDay(for: start)
            let endDate = Calendar.current.startOfDay(for: start.addingTimeInterval(86400))
            let raw = try await networking.fetchHistory(deviceSN: currentDevice.deviceSN, variables: rawGraphVariables.map { $0.variable }, start: startDate, end: endDate)
            let rawData: [ParameterGraphValue] = raw.datas.flatMap { response -> [ParameterGraphValue] in
                guard let rawVariable = configManager.variables.first(where: { $0.variable == response.variable }) else { return [] }

                return response.data.compactMap {
                    ParameterGraphValue(date: $0.time, queryDate: queryDate, value: $0.value, variable: rawVariable)
                }
            }

            await MainActor.run {
                self.rawData = rawData
                self.refresh()
                prepareExport()
                setState(.inactive)
                self.lastLoadState = LastLoadState(lastLoadTime: .now, loadState: ParametersGraphLoadState(displayMode: displayMode, variables: graphVariables))
            }
        } catch {
            setState(.error(error, "Could not load, check your connection"))
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
        Task { await load() }
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

enum AxisUnit {
    case mixed
    case consistent(String)
}

struct ParametersGraphLoadState {
    let displayMode: ParametersGraphDisplayMode
    let variables: [ParameterGraphVariable]
}
