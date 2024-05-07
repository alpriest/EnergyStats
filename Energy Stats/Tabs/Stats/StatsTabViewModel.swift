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

class StatsTabViewModel: ObservableObject, HasLoadState {
    private let haptic = UIImpactFeedbackGenerator()
    private let configManager: ConfigManaging
    private let networking: Networking
    private let approximationsCalculator: ApproximationsCalculator

    @Published var state = LoadState.inactive
    @Published var displayMode: StatsDisplayMode = .day(Date()) {
        didSet {
            Task { @MainActor in
                selectedDate = nil
                valuesAtTime = nil
                await load()
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
    @Published var selfSufficiencyAtDateTime: [SelfSufficiencyGraphVariable] = []
    @Published var scale: ClosedRange<Date> = ClosedRange(uncheckedBounds: (lower: Date.now, upper: Date.now))

    init(networking: Networking, configManager: ConfigManaging) {
        self.networking = networking
        self.configManager = configManager
        self.approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
        self.fetcher = StatsDataFetcher(networking: networking, approximationsCalculator: approximationsCalculator)

        haptic.prepare()

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        addDeviceChangeObserver()
    }

    func addDeviceChangeObserver() {
        guard currentDeviceCancellable == nil else { return }

        currentDeviceCancellable = configManager.currentDevice.sink { device in
            guard let device else { return }

            Task { await self.updateGraphVariables(for: device) }
        }
    }

    @objc
    func didBecomeActiveNotification() {
        if hasData {
            Task { await self.load() }
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
                              .loads]
                .compactMap { $0 }
                .map {
                    StatsGraphVariable($0)
                }
        }
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }

        setState(.active("Loading"))

        if graphVariables.isEmpty {
            await updateGraphVariables(for: currentDevice)
        }

        let reportVariables: [ReportVariable] = [.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads]

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

            await MainActor.run {
                self.totals = totals
                self.unit = displayMode.unit()
                self.rawData = updatedData
                calculateApproximations()
                refresh()
                prepareExport()
                setState(.inactive)
            }
        } catch {
            await MainActor.run {
                setState(.error(error, "Could not load, check your connection"))
            }
        }
    }

    func calculateApproximations() {
        guard let grid = totals[ReportVariable.gridConsumption],
              let feedIn = totals[ReportVariable.feedIn],
              let loads = totals[ReportVariable.loads] else { return }

        let batteryCharge = totals[ReportVariable.chargeEnergyToTal]
        let batteryDischarge = totals[ReportVariable.dischargeEnergyToTal]

        approximationsViewModel = approximationsCalculator.calculateApproximations(grid: grid,
                                                                                   feedIn: feedIn,
                                                                                   loads: loads,
                                                                                   batteryCharge: batteryCharge ?? 0,
                                                                                   batteryDischarge: batteryDischarge ?? 0)

        selfSufficiencyAtDateTime = calculateSelfSufficiencyAcrossTimePeriod()
    }

    func calculateSelfSufficiencyAcrossTimePeriod() -> [SelfSufficiencyGraphVariable] {
        let dates = Set(rawData.map { $0.date })
        var selfSufficiencyAtDateTime: [Date: Double] = [:]

        for date in dates {
            let valuesAtTime = ValuesAtTime(values: rawData.filter { $0.date == date })

            if let grid = valuesAtTime.values.first(where: { $0.type == .gridConsumption })?.value,
               let feedIn = valuesAtTime.values.first(where: { $0.type == .feedIn })?.value,
               let loads = valuesAtTime.values.first(where: { $0.type == .loads })?.value,
               let batteryCharge = valuesAtTime.values.first(where: { $0.type == .chargeEnergyToTal })?.value,
               let batteryDischarge = valuesAtTime.values.first(where: { $0.type == .dischargeEnergyToTal })?.value,
                let selfSufficiency = approximationsCalculator.calculateApproximations(
                    grid: grid,
                    feedIn: feedIn,
                    loads: loads,
                    batteryCharge: batteryCharge,
                    batteryDischarge: batteryDischarge
                ).netSelfSufficiencyEstimateValue {
                selfSufficiencyAtDateTime[date] = selfSufficiency
            }
        }

        return selfSufficiencyAtDateTime.map {
            SelfSufficiencyGraphVariable(date: $0.key, value: $0.value)
        }
        .filter { $0.date <= Date.now }
        .sorted(by: { $1.date > $0.date })
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type.networkTitle }

        let refreshedData = rawData
            .filter { !hiddenVariableTypes.contains($0.type.networkTitle) }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })

        max = refreshedData.max(by: { lhs, rhs in
            lhs.value < rhs.value
        })
        if let min = refreshedData.min(by: { $0.date < $1.date }),
           let max = refreshedData.max(by: { $0.date < $1.date }) {
            scale = ClosedRange(uncheckedBounds: (min.date, max.date))
        }
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
        let visibleVariableTypes = graphVariables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.type) })

        if let maxDate = max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        if let grid = result.values.first(where: { $0.type == .gridConsumption })?.value,
           let feedIn = result.values.first(where: { $0.type == .feedIn })?.value,
           let loads = result.values.first(where: { $0.type == .loads })?.value,
           let batteryCharge = result.values.first(where: { $0.type == .chargeEnergyToTal })?.value,
           let batteryDischarge = result.values.first(where: { $0.type == .dischargeEnergyToTal })?.value
        {
            approximationsViewModel = approximationsCalculator.calculateApproximations(
                grid: grid,
                feedIn: feedIn,
                loads: loads,
                batteryCharge: batteryCharge,
                batteryDischarge: batteryDischarge
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
            [$0.type.networkTitle, $0.date.iso8601(), String(describing: $0.value)].lazy.joined(separator: ",")
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
