//
//  ApproximationsCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/11/2023.
//

import Foundation
import Energy_Stats_Core
struct ApproximationsCalculator {
    let configManager: ConfigManaging
    let networking: FoxESSNetworking

    func calculateApproximations(
        grid: Double,
        feedIn: Double,
        loads: Double,
        batteryCharge: Double,
        batteryDischarge: Double,
        earnings: EarningsResponse?
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

        let financialModel: EnergyStatsFinancialModel?
        let totalsViewModel = TotalsViewModel(grid: grid,
                                              feedIn: feedIn,
                                              loads: loads,
                                              batteryCharge: batteryCharge,
                                              batteryDischarge: batteryDischarge)

        if configManager.financialModel == .energyStats {
            financialModel = EnergyStatsFinancialModel(
                totalsViewModel: totalsViewModel,
                config: configManager,
                currencySymbol: configManager.currencySymbol
            )
        } else {
            financialModel = nil
        }

        return ApproximationsViewModel(
            netSelfSufficiencyEstimate: asPercent(netResult),
            netSelfSufficiencyEstimateCalculationBreakdown: netResultCalculationBreakdown,
            absoluteSelfSufficiencyEstimate: asPercent(absoluteResult),
            absoluteSelfSufficiencyEstimateCalculationBreakdown: absoluteResultCalculationBreakdown,
            financialModel: financialModel,
            earnings: earnings,
            homeUsage: loads,
            totalsViewModel: totalsViewModel
        )
    }

    func generateTotals(
        currentDevice: Device,
        reportType: ReportType,
        queryDate: QueryDate,
        reports: [ReportResponse],
        reportVariables: [ReportVariable]
    ) async throws -> [ReportVariable: Double] {
        var totals = [ReportVariable: Double]()

        if case .day = reportType {
            let monthlyReports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate, reportType: .month)

            monthlyReports.forEach { reportResponse in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

                totals[reportVariable] = reportResponse.data.first { $0.index == queryDate.day }?.value ?? 0.0
            }
        } else {
            reports.forEach { reportResponse in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

                totals[reportVariable] = reportResponse.data.map { abs($0.value) }.reduce(0.0, +)
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
