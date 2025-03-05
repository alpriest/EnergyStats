//
//  StatsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Combine
import Energy_Stats_Core
import Foundation
import SwiftUI

struct ApproximationsViewModel {
    let netSelfSufficiencyEstimateValue: Double?
    let netSelfSufficiencyEstimate: String?
    let netSelfSufficiencyEstimateCalculationBreakdown: CalculationBreakdown
    let absoluteSelfSufficiencyEstimateValue: Double?
    let absoluteSelfSufficiencyEstimate: String?
    let absoluteSelfSufficiencyEstimateCalculationBreakdown: CalculationBreakdown
    let financialModel: EnergyStatsFinancialModel?
    let homeUsage: Double?
    let totalsViewModel: TotalsViewModel?
}

class StatsTabViewModel: ObservableObject, HasLoadState, VisibilityTracking {
    private let haptic = UIImpactFeedbackGenerator()
    private let configManager: ConfigManaging
    private let networking: Networking
    private let approximationsCalculator: ApproximationsCalculator

    @Published var state = LoadState.inactive
    @Published var displayMode: StatsGraphDisplayMode = .day(Date()) {
        didSet {
            Task { @MainActor in
                selectedDate = nil
                valuesAtTime = nil
                self.performLoad()
            }
        }
    }

    @Published var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    @Published var selectedDate: Date?

    var stride: Int = 3
    private var rawData: [StatsGraphValue] = []
    @Published var data: [StatsGraphValue] = []
    @Published var unit: Calendar.Component = .hour
    @Published var graphVariables: [StatsGraphVariable] = []
    @Published var approximationsViewModel: ApproximationsViewModel? = nil
    private var totals: [ReportVariable: Double] = [:]
    private var max: StatsGraphValue?
    var exportFile: CSVTextFile?
    private var currentDeviceCancellable: AnyCancellable?
    private let fetcher: StatsDataFetcher
    @Published var selfSufficiencyAtDateTime: [StatsGraphValue] = []
    @Published var yScale: ClosedRange<Double> = ClosedRange(uncheckedBounds: (lower: 0, upper: 0))
    private var themeCancellable: AnyCancellable?
    var visible = false
    var lastLoadState: LastLoadState<StatsGraphDisplayMode>?
    private var loadTask: Task<Void, Never>?

    init(networking: Networking, configManager: ConfigManaging) {
        self.networking = networking
        self.configManager = configManager
        self.approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
        self.fetcher = StatsDataFetcher(networking: networking, approximationsCalculator: approximationsCalculator)

        haptic.prepare()

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        addDeviceChangeObserver()
        addThemeChangeObserver()
    }

    private func addDeviceChangeObserver() {
        guard currentDeviceCancellable == nil else { return }

        currentDeviceCancellable = configManager.currentDevice.sink { device in
            guard let device else { return }

            Task { await self.updateGraphVariables(for: device) }
        }
    }

    private func addThemeChangeObserver() {
        themeCancellable = configManager.appSettingsPublisher.sink { [weak self] _ in
            guard let self else { return }

            if let device = configManager.currentDevice.value {
                Task { await self.updateGraphVariables(for: device) }
            }
        }
    }

    @objc
    func didBecomeActiveNotification() {
        if hasData, visible {
            performLoad()
        }
    }

    private var hasData: Bool {
        totals.isEmpty == false
    }

    private func updateGraphVariables(for device: Device) async {
        await MainActor.run {
            graphVariables = [.generation,
                              ReportVariable.feedIn,
                              .gridConsumption,
                              configManager.hasBattery ? .chargeEnergyToTal : nil,
                              configManager.hasBattery ? .dischargeEnergyToTal : nil,
                              .loads,
                              (configManager.selfSufficiencyEstimateMode != .off && configManager.showSelfSufficiencyStatsGraphOverlay) ? .selfSufficiency : nil,
                              .pvEnergyTotal]
                .compactMap { $0 }
                .map {
                    StatsGraphVariable($0)
                }
        }
    }

    func performLoad() {
        loadTask?.cancel()
        loadTask = Task { @MainActor in await self.load() }
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }
        guard requiresLoad() else { return }

        await setState(.active("Loading"))

        if graphVariables.isEmpty {
            await updateGraphVariables(for: currentDevice)
        }

        let reportVariables: [ReportVariable] = [.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads, .pvEnergyTotal]

        do {
            let updatedData: [StatsGraphValue]
            let totals: [ReportVariable: Double]

            if case .custom(let start, let end) = displayMode {
                (updatedData, totals) = try await fetcher.fetchCustomData(
                    device: currentDevice,
                    start: start,
                    end: end,
                    reportVariables: reportVariables,
                    displayMode: displayMode
                )
            } else {
                (updatedData, totals) = try await fetcher.fetchData(
                    device: currentDevice,
                    reportVariables: reportVariables,
                    displayMode: displayMode
                )
            }

            if Task.isCancelled { return }

            await MainActor.run {
                self.totals = totals
                self.unit = displayMode.unit()
                self.rawData = updatedData + calculateSelfSufficiencyAcrossTimePeriod(updatedData)
                calculateApproximations()
                refresh()
                prepareExport()
                Task { await setState(.inactive) }
                self.lastLoadState = LastLoadState(lastLoadTime: .now, loadState: displayMode)
            }
        } catch {
            if Task.isCancelled { return }

            await setState(.error(error, "Could not load from Fox OpenAPI"))
        }
    }

    func calculateApproximations() {
        guard let grid = totals[ReportVariable.gridConsumption],
              let feedIn = totals[ReportVariable.feedIn],
              let loads = totals[ReportVariable.loads],
              let solar = totals[ReportVariable.pvEnergyTotal] else { return }

        let batteryCharge = totals[ReportVariable.chargeEnergyToTal]
        let batteryDischarge = totals[ReportVariable.dischargeEnergyToTal]

        approximationsViewModel = approximationsCalculator.calculateApproximations(grid: grid,
                                                                                   feedIn: feedIn,
                                                                                   loads: loads,
                                                                                   batteryCharge: batteryCharge ?? 0,
                                                                                   batteryDischarge: batteryDischarge ?? 0,
                                                                                   solar: solar)
    }

    func calculateSelfSufficiencyAcrossTimePeriod(_ rawData: [StatsGraphValue]) -> [StatsGraphValue] {
        let dates = Set(rawData.map { $0.date })
        var selfSufficiencyAtDateTime: [Date: Double] = [:]
        let actualMax = rawData.max(by: { $0.graphValue < $1.graphValue })?.graphValue ?? 0
        let scaleMax = (actualMax + Swift.max(actualMax * 0.1, 0.5)).roundUpToNearestHalf()

        for date in dates {
            let valuesAtTime = ValuesAtTime(values: rawData.filter { $0.date == date })

            if let grid = valuesAtTime.values.first(where: { $0.type == .gridConsumption })?.graphValue,
               let feedIn = valuesAtTime.values.first(where: { $0.type == .feedIn })?.graphValue,
               let loads = valuesAtTime.values.first(where: { $0.type == .loads })?.graphValue,
               let batteryCharge = valuesAtTime.values.first(where: { $0.type == .chargeEnergyToTal })?.graphValue,
               let batteryDischarge = valuesAtTime.values.first(where: { $0.type == .dischargeEnergyToTal })?.graphValue,
               let solar = valuesAtTime.values.first(where: { $0.type == .pvEnergyTotal })?.graphValue
            {
                let approximations = approximationsCalculator.calculateApproximations(
                    grid: grid,
                    feedIn: feedIn,
                    loads: loads,
                    batteryCharge: batteryCharge,
                    batteryDischarge: batteryDischarge,
                    solar: solar
                )

                switch configManager.selfSufficiencyEstimateMode {
                case .absolute:
                    if let value = approximations.absoluteSelfSufficiencyEstimateValue {
                        selfSufficiencyAtDateTime[date] = value
                    }
                case .net:
                    if let value = approximations.netSelfSufficiencyEstimateValue {
                        selfSufficiencyAtDateTime[date] = value
                    }
                default:
                    ()
                }
            }
        }

        yScale = ClosedRange(uncheckedBounds: (lower: 0, upper: scaleMax))

        return selfSufficiencyAtDateTime
            .map {
                StatsGraphValue(type: .selfSufficiency, date: $0.key, graphValue: scaleMax * $0.value, displayValue: $0.value) // Normalise amount to be on the same scale as the stats
            }
            .sorted(by: { $1.date > $0.date })
            .filter { $0.date <= Date.now }
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type.networkTitle }

        let refreshedData = rawData
            .filter { !hiddenVariableTypes.contains($0.type.networkTitle) }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })

        max = refreshedData.max(by: { lhs, rhs in
            lhs.graphValue < rhs.graphValue
        })
        data = refreshedData
    }

    func total(of type: ReportVariable?) -> Double? {
        guard let type = type else { return nil }
        guard totals.keys.contains(type) else { return nil }

        return totals[type]
    }

    func toggle(visibilityOf variable: StatsGraphVariable) {
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

    func data(at date: Date?) -> ValuesAtTime<StatsGraphValue> {
        guard let date else { return ValuesAtTime(values: []) }
        let variableTypes = graphVariables.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && variableTypes.contains($0.type) })

        if let maxDate = max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        if let grid = result.values.first(where: { $0.type == .gridConsumption })?.graphValue,
           let feedIn = result.values.first(where: { $0.type == .feedIn })?.graphValue,
           let loads = result.values.first(where: { $0.type == .loads })?.graphValue,
           let batteryCharge = result.values.first(where: { $0.type == .chargeEnergyToTal })?.graphValue,
           let batteryDischarge = result.values.first(where: { $0.type == .dischargeEnergyToTal })?.graphValue,
           let solar = result.values.first(where: { $0.type == .pvEnergyTotal })?.graphValue
        {
            approximationsViewModel = approximationsCalculator.calculateApproximations(
                grid: grid,
                feedIn: feedIn,
                loads: loads,
                batteryCharge: batteryCharge,
                batteryDischarge: batteryDischarge,
                solar: solar
            )
        }

        return result
    }

    func selectedDateFormatted(_ date: Date) -> String {
        switch displayMode {
        case .day:
            return DateFormatter.dayHour.string(from: date)
        case .month:
            return DateFormatter.dayMonth.string(from: date)
        case .year:
            return DateFormatter.monthYear.string(from: date)
        case .custom:
            return DateFormatter.dayMonth.string(from: date)
        }
    }

    func prepareExport() {
        let headers = ["Type", "Date", "Value"].lazy.joined(separator: ",")
        let rows = rawData.map {
            [$0.type.networkTitle, $0.date.iso8601(), $0.formatted(2)].lazy.joined(separator: ",")
        }

        let text = ([headers] + rows).joined(separator: "\n")
        let exportFileName: String

        switch displayMode {
        case .day(let date):
            let name = dateName(from: date)
            exportFileName = "energystats_stats_\(name).csv"
        case .month(let month, let year):
            exportFileName = "energystats_stats_\(year)_\(month + 1).csv"
        case .year(let year):
            exportFileName = "energystats_stats_\(year).csv"
        case .custom(let start, let end):
            let startName = dateName(from: start)
            let endName = dateName(from: end)
            exportFileName = "energystats_stats_\(startName)_\(endName).csv"
        }

        exportFile = CSVTextFile(text: text, filename: exportFileName)
    }
}

extension StatsTabViewModel: LoadTracking {
    func requiresLoad() -> Bool {
        guard let lastLoadState else { return true }

        let calendar = Calendar.current
        let lastLoadHour = calendar.dateComponents([.hour], from: lastLoadState.lastLoadTime).hour ?? 0
        let currentHour = calendar.dateComponents([.hour], from: .now).hour ?? 0

        let sufficientTimeHasPassed = !calendar.isDateInToday(lastLoadState.lastLoadTime) || lastLoadHour != currentHour
        let viewDataHasChanged = lastLoadState.loadState != displayMode

        return sufficientTimeHasPassed || viewDataHasChanged
    }
}

private extension StatsTabViewModel {
    func dateName(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        if let year = components.year, let month = components.month, let day = components.day {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return "\(year)_\(month)_\(day)"
        } else {
            return "unknown_date"
        }
    }
}
