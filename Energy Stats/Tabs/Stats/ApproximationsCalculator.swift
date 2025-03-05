//
//  ApproximationsCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/11/2023.
//

import Energy_Stats_Core
import Foundation

struct ApproximationsCalculator {
    let configManager: ConfigManaging
    let networking: Networking

    func calculateApproximations(
        grid: Double,
        feedIn: Double,
        loads: Double,
        batteryCharge: Double,
        batteryDischarge: Double,
        solar: Double
    ) -> ApproximationsViewModel {
        let (netResult, netResultCalculationBreakdown) = NetSelfSufficiencyCalculator.calculate(
            grid: grid,
            feedIn: feedIn,
            loads: loads,
            batteryCharge: batteryCharge,
            batteryDischarge: batteryDischarge
        )

        let (absoluteResult, absoluteResultCalculationBreakdown) = AbsoluteSelfSufficiencyCalculator.calculate(
            loads: loads,
            grid: grid
        )

        let totalsViewModel = TotalsViewModel(grid: grid,
                                              feedIn: feedIn,
                                              loads: loads,
                                              solar: solar)

        let financialModel = EnergyStatsFinancialModel(
            totalsViewModel: totalsViewModel,
            config: configManager
        )

        return ApproximationsViewModel(
            netSelfSufficiencyEstimateValue: netResult,
            netSelfSufficiencyEstimate: asPercent(netResult),
            netSelfSufficiencyEstimateCalculationBreakdown: netResultCalculationBreakdown,
            absoluteSelfSufficiencyEstimateValue: absoluteResult,
            absoluteSelfSufficiencyEstimate: asPercent(absoluteResult),
            absoluteSelfSufficiencyEstimateCalculationBreakdown: absoluteResultCalculationBreakdown,
            financialModel: financialModel,
            homeUsage: loads,
            totalsViewModel: totalsViewModel
        )
    }

    func generateTotals(
        currentDevice: Device,
        reportType: ReportType,
        queryDate: QueryDate? = nil,
        reports: [OpenReportResponse],
        reportVariables: [ReportVariable]
    ) async throws -> [ReportVariable: Double] {
        var totals = [ReportVariable: Double]()

        if case .day = reportType, let queryDate {
            let monthlyReports = try await networking.fetchReport(deviceSN: currentDevice.deviceSN, variables: reportVariables, queryDate: queryDate, reportType: .month)

            monthlyReports.forEach { reportResponse in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

                totals[reportVariable] = reportResponse.values.first { $0.index == queryDate.day }?.value ?? 0.0
            }
        } else {
            reports.forEach { reportResponse in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

                totals[reportVariable] = reportResponse.values.map { abs($0.value) }.reduce(0.0, +)
            }
        }

        return totals
    }

    func asPercent(_ value: Double) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 1

        return numberFormatter.string(from: NSNumber(value: value))
    }
}
