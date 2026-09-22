//
//  StatsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Combine
import Energy_Stats_Core
import Foundation
import Observation
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

@Observable
class StatsTabViewModel: HasLoadState, VisibilityTracking {
    private let haptic = UIImpactFeedbackGenerator()
    private var configManager: ConfigManaging
    private let approximationsCalculator: ApproximationsCalculator
    private let derivedDataCalculator: StatsDerivedDataCalculator

    var state = LoadState.inactive
    var displayMode: StatsGraphDisplayMode = .day(Date()) {
        didSet {
            Task { @MainActor in
                selectedDate = nil
                valuesAtTime = nil
                self.performLoad()
                self.updateHeaderTitle()
            }
        }
    }

    var touchHeaderTitle: LocalizedStringKey = "stats_header_by_time"
    var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    var selectedDate: Date?
    var statsTimeUsageGraphStyle: StatsTimeUsageGraphStyle {
        didSet {
            configManager.statsTimeUsageGraphStyle = statsTimeUsageGraphStyle
        }
    }

    private var sourceData: [StatsGraphValue] = []
    var displayedData: [StatsGraphValue] = []
    var unit: Calendar.Component = .hour
    private var maximum: StatsGraphValue?
    var yScale: ClosedRange<Double> = ClosedRange(uncheckedBounds: (lower: 0, upper: 0))
    var xScale: ClosedRange<Date> = ClosedRange(
        uncheckedBounds: (lower: Date().startOfDay(), upper: Date().endOfDay())
    )
    var graphVariables: [StatsGraphVariable] = []
    var approximationsViewModel: ApproximationsViewModel? = nil
    private var totals: [ReportVariable: Double] = [:]
    private var max: StatsGraphValue? { maximum }
    var exportFile: TextFile?
    private var currentDeviceCancellable: AnyCancellable?
    private let loadCoordinator: StatsLoadCoordinator
    var selfSufficiencyAtDateTime: [StatsGraphValue] = []
    private var themeCancellable: AnyCancellable?
    var visible = false
    var lastLoadState: LastLoadState<StatsGraphDisplayMode>?
    private var loadTask: Task<Void, Never>?

    init(networking: Networking, configManager: ConfigManaging) {
        self.configManager = configManager
        let approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
        self.approximationsCalculator = approximationsCalculator
        self.derivedDataCalculator = StatsDerivedDataCalculator(approximationsCalculator: approximationsCalculator)
        self.loadCoordinator = StatsLoadCoordinator(
            networking: networking,
            approximationsCalculator: approximationsCalculator
        )
        self.statsTimeUsageGraphStyle = configManager.statsTimeUsageGraphStyle

        haptic.prepare()

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        addDeviceChangeObserver()
        addThemeChangeObserver()
    }

    private func addDeviceChangeObserver() {
        guard currentDeviceCancellable == nil else { return }

        currentDeviceCancellable = configManager.currentDevice
            .removeDuplicates()
            .sink { device in
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
            graphVariables = [device.hasPV ? .pvEnergyTotal : nil,
                              .gridConsumption,
                              configManager.hasBattery ? .dischargeEnergyToTal : nil,
                              .loads,
                              ReportVariable.feedIn,
                              configManager.hasBattery ? .chargeEnergyToTal : nil,
                              configManager.showOutputEnergyOnStats ? .generation : nil,
                              (configManager.selfSufficiencyEstimateMode != .off && configManager.showSelfSufficiencyStatsGraphOverlay) ? .selfSufficiency : nil,
                              configManager.showInverterConsumption ? .inverterConsumption : nil,
                              configManager.showBatterySOCOnDailyStats ? .batterySOC : nil]
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

        await setState(.active(.loading))

        if graphVariables.isEmpty {
            await updateGraphVariables(for: currentDevice)
        }

        let reportVariables: [ReportVariable] = [
            .feedIn,
            configManager.showOutputEnergyOnStats ? .generation : nil,
            .chargeEnergyToTal,
            .dischargeEnergyToTal,
            .gridConsumption,
            .loads,
            .pvEnergyTotal
        ].compactMap { $0 }

        do {
            let loadResult = try await loadCoordinator.load(
                device: currentDevice,
                displayMode: displayMode,
                reportVariables: reportVariables,
                includeBatterySOC: configManager.showBatterySOCOnDailyStats
            )

            if Task.isCancelled { return }

            await MainActor.run {
                self.totals = loadResult.totals
                self.unit = displayMode.unit()
                let selfSufficiencyData = derivedDataCalculator.calculateSelfSufficiencyAcrossTimePeriod(
                    loadResult.reportData,
                    mode: configManager.selfSufficiencyEstimateMode
                )
                let inverterConsumption = derivedDataCalculator.calculateInverterConsumptionAcrossTimePeriod(loadResult.reportData)

                self.totals[.inverterConsumption] = inverterConsumption.total
                self.sourceData = loadResult.reportData + selfSufficiencyData + inverterConsumption.values + loadResult.batterySOCData
                calculateApproximations()
                refresh()
                exportFile = prepareExport(rawData: sourceData)
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

    func updateYScale() {
        let visibleMax = actualMax(of: displayedData)
        let scaleMax = (visibleMax + Swift.max(visibleMax * 0.1, 0.5)).roundUpToNearestHalf()

        yScale = ClosedRange(uncheckedBounds: (lower: 0, upper: scaleMax))
    }

    func updateXScale() {
        xScale = switch displayMode {
        case .day(let date):
            date.startOfDay()...date.endOfDay()
        case .month(let month, let year):
            {
                let when = Date.from(year: year, month: month + 1)
                return when.startOfMonth()...when.endOfMonth()
            }()
        case .year(let year):
            {
                let when = Date.from(year: year, month: 1)
                return when.startOfYear()...when.endOfYear()
            }()
        case .custom(let start, let end, _):
            start...end
        }
    }

    private func actualMax(of data: [StatsGraphValue]) -> Double {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type.networkTitle }

        return data
            .filter { $0.isForNormalGraph }
            .filter { !hiddenVariableTypes.contains($0.type.networkTitle) }
            .max(by: { $0.graphValue < $1.graphValue })?.graphValue ?? 0
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type.networkTitle }

        let regularScaleDatasets = sourceData.filter { $0.type != .selfSufficiency && $0.type != .batterySOC }
        let refreshedData = (regularScaleDatasets + updateScaledDatasets())
            .filter { !hiddenVariableTypes.contains($0.type.networkTitle) }
            .filter { $0.date < Date() }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })

        maximum = refreshedData.max(by: { lhs, rhs in
            lhs.graphValue < rhs.graphValue
        })
        displayedData = refreshedData
        updateYScale()
        updateXScale()
        updateHeaderTitle()
    }

    private func updateHeaderTitle() {
        touchHeaderTitle = switch displayMode {
        case .day:
            "stats_header_by_time"
        case .month, .custom:
            "stats_header_by_day"
        case .year:
            "stats_header_by_month"
        }
    }

    private func updateScaledDatasets() -> [StatsGraphValue] {
        let actualMax = actualMax(of: sourceData)
        let scaleMax = (actualMax + Swift.max(actualMax * 0.1, 0.5)).roundUpToNearestHalf()

        var normalisedData: [StatsGraphValue] = sourceData
            .filter { $0.type == .selfSufficiency }
            .map { StatsGraphValue(type: $0.type, date: $0.date, graphValue: scaleMax * $0.graphValue, displayValue: $0.displayValue) }

        normalisedData.append(contentsOf:
            sourceData
                .filter { $0.type == .batterySOC }
                .map { StatsGraphValue(type: $0.type, date: $0.date, graphValue: scaleMax * ($0.graphValue / 100.0), displayValue: $0.displayValue) }
        )

        return normalisedData
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
        updateYScale()
    }

    func data(at date: Date?) -> ValuesAtTime<StatsGraphValue> {
        guard let date else { return ValuesAtTime(values: []) }
        let variableTypes = graphVariables.map { $0.type }
        var filteredRawData = sourceData.filter {
            $0.date == date && variableTypes.contains($0.type)
        }

        if !filteredRawData.contains(where: { $0.isForInverterConsumptionGraph }) {
            filteredRawData += [StatsGraphValue(type: .inverterConsumption, date: date, graphValue: 0, displayValue: 0)]
        }

        if !filteredRawData.contains(where: { $0.isForBatterySOCGraph }) {
            if let nearest = sourceData.filter({ $0.isForBatterySOCGraph }).nearestTo(date: date) {
                filteredRawData += [nearest]
            }
        }

        let result = ValuesAtTime(values: filteredRawData)

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
            return date.dayHourString()
        case .month:
            return date.dayMonthString()
        case .year:
            return date.monthYearString()
        case .custom(_, _, let unit):
            switch unit {
            case .days:
                return date.dayMonthString()
            case .months:
                return date.monthYearString()
            }
        }
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

extension [StatsGraphValue] {
    func nearestTo(date: Date) -> StatsGraphValue? {
        var nearestTimeInterval: TimeInterval = .infinity
        var nearestData: StatsGraphValue?

        forEach { value in
            if abs(value.date.timeIntervalSince(date)) < nearestTimeInterval {
                nearestData = value
                nearestTimeInterval = abs(value.date.timeIntervalSince(date))
            }
        }

        return nearestData
    }
}
