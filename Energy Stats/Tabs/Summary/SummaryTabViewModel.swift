//
//  SummaryTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/11/2023.
//

import Combine
import Energy_Stats_Core
import Foundation
import SwiftUI

struct SolarGenerationPeriodAmount {
    let year: Int
    let month: Int
    let amount: Double
}

struct SummaryViewData: Copiable, Equatable {
    struct FinancialData: Equatable {
        let exportIncome: Double
        let gridImportAvoided: Double
        let totalBenefit: Double
        let payback: PaybackData?
        
        struct PaybackData: Equatable {
            let paybackMonths: Int
            let installationPurchasePrice: String
            let infoText: LocalizedStringKey
            
            init?(
                paybackMonths: Int?,
                purchasePrice: String?,
                oldestDataDate: Date
            ) {
                guard let paybackMonths, let purchasePrice else { return nil }
                
                self.paybackMonths = paybackMonths
                self.installationPurchasePrice = purchasePrice
                self.infoText = "Assuming system was purchased around \(oldestDataDate.monthYearString()) for \(installationPurchasePrice)."
            }
        }
    }
    
    struct BestSolarData: Equatable {
        let description: String
        let amount: Double
        let period: TimeGrouping
    }
    
    let solar: Double?
    let homeUsage: Double?
    let financialData: FinancialData?
    var bestSolar: BestSolarData?
    let hasPV: Bool
    let oldestDataDate: String
    let latestDataDate: String
    var currencySymbol: String
    
    func create(copying previous: SummaryViewData) -> SummaryViewData {
        SummaryViewData(
            solar: previous.solar,
            homeUsage: previous.homeUsage,
            financialData: previous.financialData,
            bestSolar: previous.bestSolar,
            hasPV: previous.hasPV,
            oldestDataDate: previous.oldestDataDate,
            latestDataDate: previous.latestDataDate,
            currencySymbol: previous.currencySymbol
        )
    }
}

class SummaryTabViewModel: ObservableObject, HasLoadState {
    private let networking: Networking
    private var configManager: ConfigManaging
    @Published var viewData: SummaryViewData? = nil
    private let approximationsCalculator: ApproximationsCalculator
    private var themeChangeCancellable: AnyCancellable?
    @Published var summaryDateRange: SummaryDateRange
    private let reportVariables = [ReportVariable.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads, .pvEnergyTotal]
    @Published var state: LoadState = .inactive
    private var solarGenerationByMonth: [SolarGenerationPeriodAmount] = []
    private var grouping: TimeGrouping = .month
    
    init(configManager: ConfigManaging, networking: Networking) {
        self.networking = networking
        self.configManager = configManager
        summaryDateRange = configManager.summaryDateRange
        approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
        themeChangeCancellable = self.configManager.appSettingsPublisher.sink { theme in
            Task { @MainActor in
                self.viewData = self.viewData?.copy { $0.currencySymbol = theme.currencySymbol }
            }
        }
    }
    
    func load() {
        guard viewData == nil else { return }
        guard let currentDevice = configManager.currentDevice.value else { return }
        guard !state.isActive else { return }
        
        solarGenerationByMonth = []
        
        Task { @MainActor in
            await setState(.active(.loading))
            
            let (totals, oldestDataDate) = try await fetchAllYears(device: currentDevice)
            
            if let approximationsViewModel = makeApproximationsViewModel(totals: totals) {
                let financialData: SummaryViewData.FinancialData? = if let model = approximationsViewModel.financialModel {
                    SummaryViewData.FinancialData(
                        exportIncome: model.exportIncome.amount,
                        gridImportAvoided: model.solarSaving.amount,
                        totalBenefit: model.total.amount,
                        payback: SummaryViewData.FinancialData.PaybackData(
                            paybackMonths: model.payback(installDate: oldestDataDate)?.monthsRemaining,
                            purchasePrice: configManager.installationPurchasePrice.roundedToString(
                                decimalPlaces: 0,
                                currencySymbol: configManager.currencySymbol
                            ),
                            oldestDataDate: oldestDataDate
                        )
                    )
                } else { nil }
                
                let bestSolarData: SummaryViewData.BestSolarData? = findBest(grouping: grouping, in: solarGenerationByMonth)
                
                self.viewData = SummaryViewData(
                    solar: approximationsViewModel.totalsViewModel?.solar,
                    homeUsage: approximationsViewModel.totalsViewModel?.home,
                    financialData: financialData,
                    bestSolar: bestSolarData,
                    hasPV: configManager.currentDevice.value?.hasPV ?? false,
                    oldestDataDate: oldestDataDate.monthYearString(),
                    latestDataDate: toDateDescription,
                    currencySymbol: configManager.currentAppSettings.currencySymbol
                )
            }
            
            await setState(.inactive)
        }
    }
    
    func setDateRange(dateRange: SummaryDateRange) {
        configManager.summaryDateRange = dateRange
        summaryDateRange = dateRange
        viewData = nil
        load()
    }
    
    func toggleBestSolarGrouping() {
        guard let viewData else { return }

        grouping = switch grouping {
        case .month:
            .year
        case .year:
            .month
        }

        self.viewData = viewData.copy {
            $0.bestSolar = findBest(grouping: grouping, in: solarGenerationByMonth)
        }
    }
    
    private var fromYear: Int {
        switch configManager.summaryDateRange {
        case .automatic:
            2020
        case .manual(let from, _):
            from.year
        }
    }
    
    private var toYear: Int {
        switch configManager.summaryDateRange {
        case .automatic:
            Calendar.current.component(.year, from: Date())
        case .manual(_, let to):
            to.year
        }
    }
    
    private var toDateDescription: String {
        switch configManager.summaryDateRange {
        case .automatic:
            "present"
        case .manual(_, let to):
            "\(to.monthYearString()) (manually selected)"
        }
    }
    
    private func fetchAllYears(device: Device) async throws -> ([ReportVariable: Double], Date) {
        var totals = [ReportVariable: Double]()
        var hasFinished = false
        var oldestDataDate: Date = Date.now
        let currentYear = Calendar.current.component(.year, from: Date())

        for year in (fromYear ... toYear).reversed() {
            if hasFinished {
                break
            }
            
            do {
                let (yearlyTotals, emptyMonth) = try await fetchYear(year, device: device)
                
                if let emptyMonth {
                    switch configManager.summaryDateRange {
                    case .automatic:
                        oldestDataDate = Date.from(year: year, month: emptyMonth)
                    case .manual(let from, _):
                        oldestDataDate = from
                    }
                    
                    if toYear != currentYear {
                        if year < toYear {
                            hasFinished = true
                        }
                    } else {
                        hasFinished = true
                    }
                }
                
                yearlyTotals.forEach { variable, value in
                    totals[variable] = (totals[variable] ?? 0) + value
                }
            } catch {
                hasFinished = true
            }
        }
        
        return (totals, oldestDataDate)
    }
    
    private func fetchYear(_ year: Int, device: Device) async throws -> ([ReportVariable: Double], Int?) {
        let rawReports = try await networking.fetchReport(deviceSN: device.deviceSN,
                                                          variables: reportVariables,
                                                          queryDate: QueryDate(year: year, month: nil, day: nil),
                                                          reportType: .year)
        let reports = filterUnrequestedMonths(year: year, reports: rawReports)
        
        var totals = [ReportVariable: Double]()
        reports.forEach { reportResponse in
            guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }
            
            totals[reportVariable] = reportResponse.values.map { abs($0.value) }.reduce(0.0, +)
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        var emptyMonth: Int?
        for month in (1 ... 12).reversed() {
            var monthlyTotal: Double = 0
            
            reportVariables.forEach { variable in
                if let report = reports.first(where: { $0.variable == variable.networkTitle }),
                   let monthlyAmount = report.values.first(where: { $0.index == month })?.value
                {
                    monthlyTotal = monthlyTotal + monthlyAmount
                    
                    if report.variable == ReportVariable.pvEnergyTotal.networkTitle {
                        solarGenerationByMonth.append(SolarGenerationPeriodAmount(year: year, month: month, amount: monthlyAmount))
                    }
                }
            }
            
            if monthlyTotal == 0 && (month < currentMonth || year < currentYear) {
//            if monthlyTotal == 0 && ((month < currentMonth && year == currentYear) || month < currentMonth || year < currentYear) {
                emptyMonth = month + 1
                break
            }
        }
        
        return (totals, emptyMonth)
    }
    
    private func filterUnrequestedMonths(year: Int, reports: [OpenReportResponse]) -> [OpenReportResponse] {
        switch configManager.summaryDateRange {
        case .automatic:
            reports
        case .manual(from: let from, to: let to):
            reports.map { report in
                OpenReportResponse(variable: report.variable,
                                   unit: report.unit,
                                   values: report.values.compactMap { reportData in
                                       if year == from.year, reportData.index < from.month {
                                           return OpenReportResponse.ReportData(index: reportData.index, value: 0)
                                       }
                    
                                       if year == to.year, reportData.index > to.month {
                                           return OpenReportResponse.ReportData(index: reportData.index, value: 0)
                                       }
                    
                                       return OpenReportResponse.ReportData(index: reportData.index, value: reportData.value)
                                   })
            }
        }
    }
    
    private func makeApproximationsViewModel(
        totals: [ReportVariable: Double]
    ) -> ApproximationsViewModel? {
        guard let grid = totals[ReportVariable.gridConsumption],
              let feedIn = totals[ReportVariable.feedIn],
              let loads = totals[ReportVariable.loads],
              let batteryCharge = totals[ReportVariable.chargeEnergyToTal],
              let batteryDischarge = totals[ReportVariable.dischargeEnergyToTal],
              let solar = totals[ReportVariable.pvEnergyTotal]
        else {
            return nil
        }
                
        return approximationsCalculator.calculateApproximations(grid: grid,
                                                                feedIn: feedIn,
                                                                loads: loads,
                                                                batteryCharge: batteryCharge,
                                                                batteryDischarge: batteryDischarge,
                                                                solar: solar)
    }
    
    private func findBest(grouping: TimeGrouping, in periods: [SolarGenerationPeriodAmount]) -> SummaryViewData.BestSolarData? {
        let filteredPeriods = periods.filter { $0.amount > 0 }.removingExtremeOutliers(by: \.amount)

        switch grouping {
        case .month:
            if let period = filteredPeriods.max(by: { $0.amount < $1.amount }) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM, yyyy"
                let date = Date.from(year: period.year, month: period.month)
                return SummaryViewData.BestSolarData(description: formatter.string(from: date), amount: period.amount, period: grouping)
            }
        case .year:
            let groupedByYear = Dictionary(grouping: filteredPeriods, by: \.year)
                .map { year, periods in
                    SolarGenerationPeriodAmount(
                        year: year,
                        month: 1,
                        amount: periods.map(\.amount).reduce(0, +)
                    )
                }

            if let period = groupedByYear.max(by: { $0.amount < $1.amount }) {
                return SummaryViewData.BestSolarData(
                    description: String(period.year),
                    amount: period.amount,
                    period: grouping
                )
            }
        }
        
        return nil
    }
}

enum TimeGrouping {
    case month
    case year
    
    var title: LocalizedStringKey {
        switch self {
        case .month:
            "month"
        case .year:
            "year"
        }
    }
}

private extension Array where Element == SolarGenerationPeriodAmount {
    func removingExtremeOutliers(by keyPath: KeyPath<Element, Double>) -> [Element] {
        let values: [Double] = map { $0[keyPath: keyPath] }
        let total = values.reduce(0, +)
        let average = total / Double(values.count)

        guard average > 0 else { return self }

        return filter { period in
            let value = period[keyPath: keyPath]
            return value <= average * 3
        }
    }
}
