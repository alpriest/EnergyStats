//
//  HomeEnergyStateManager+Stats.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/07/2025.
//

import AppIntents
import SwiftData
import WidgetKit

@available(iOS 17.0, *)
@available(watchOS 9.0, *)
extension HomeEnergyStateManager {
    @MainActor
    public func isTodayStatsStateStale() async -> Bool {
        let fetchDescriptor: FetchDescriptor<StatsWidgetState> = FetchDescriptor()
        guard let widgetState = (try? modelContainer.mainContext.fetch(fetchDescriptor))?.first else { return true }

        return widgetState.lastUpdated.timeIntervalSinceNow < -60
    }

    @MainActor
    public func updateTodayStatsState(config: HomeEnergyStateManagerConfig) async throws {
        guard await isTodayStatsStateStale() else { return }
        guard let deviceSN = try config.selectedDeviceSN() else { throw ConfigManager.NoDeviceFoundError() }

        let hourlyReports = try await network.fetchReport(
            deviceSN: deviceSN,
            variables: [.loads,
                        .feedIn,
                        .gridConsumption,
                        .chargeEnergyToTal,
                        .dischargeEnergyToTal,
                        .pvEnergyTotal],
            queryDate: QueryDate(from: .now),
            reportType: .day
        )

        let dailyTotalReports = try await network.fetchReport(
            deviceSN: deviceSN,
            variables: [.loads,
                        .feedIn,
                        .gridConsumption,
                        .chargeEnergyToTal,
                        .dischargeEnergyToTal,
                        .pvEnergyTotal],
            queryDate: thisMonth(),
            reportType: .month
        )

        try calculateTodayStatsState(hourlyReports: hourlyReports, dailyTotalReports: dailyTotalReports)
    }

    @MainActor
    public func calculateTodayStatsState(hourlyReports: [OpenReportResponse], dailyTotalReports: [OpenReportResponse]) throws {
        let mapped: [ReportVariable: [OpenReportResponse.ReportData]] = hourlyReports.reduce(into: [:]) { result, response in
            guard let reportVariable = ReportVariable(rawValue: response.variable) else { return }

            result[reportVariable] = response.values.filter { $0.index < Date().hour() }
        }

        try storeTodayStatsModel(reports: mapped,
                                 totalHome: dailyTotalReports.todayValue(for: .loads) ?? 0.0,
                                 totalGridImport: dailyTotalReports.todayValue(for: .gridConsumption) ?? 0.0,
                                 totalGridExport: dailyTotalReports.todayValue(for: .feedIn) ?? 0.0,
                                 totalBatteryCharge: dailyTotalReports.todayValue(for: .chargeEnergyToTal),
                                 totalBatteryDischarge: dailyTotalReports.todayValue(for: .dischargeEnergyToTal),
                                 totalPVEnergy: dailyTotalReports.todayValue(for: .pvEnergyTotal))
    }

    @MainActor
    private func storeTodayStatsModel(
        reports: [ReportVariable: [OpenReportResponse.ReportData]],
        totalHome: Double,
        totalGridImport: Double,
        totalGridExport: Double,
        totalBatteryCharge: Double?,
        totalBatteryDischarge: Double?,
        totalPVEnergy: Double?
    ) throws {
        let state = StatsWidgetState(
            home: doubles(from: reports[.loads]),
            gridExport: doubles(from: reports[.feedIn]),
            gridImport: doubles(from: reports[.gridConsumption]),
            batteryCharge: doubles(from: reports[.chargeEnergyToTal]),
            batteryDischarge: doubles(from: reports[.dischargeEnergyToTal]),
            pvEnergy: doubles(from: reports[.pvEnergyTotal]),
            totalHome: totalHome,
            totalGridImport: totalGridImport,
            totalGridExport: totalGridExport,
            totalBatteryCharge: totalBatteryCharge,
            totalBatteryDischarge: totalBatteryDischarge,
            totalPVEnergy: totalPVEnergy
        )

        deleteTodayStatsStateEntry()

        modelContainer.mainContext.insert(state)
        modelContainer.mainContext.processPendingChanges()
    }

    @MainActor
    private func deleteTodayStatsStateEntry() {
        let fetchDescriptor: FetchDescriptor<StatsWidgetState> = FetchDescriptor()
        if let widgetState = (try? modelContainer.mainContext.fetch(fetchDescriptor))?.first {
            modelContainer.mainContext.delete(widgetState)
        }
    }

    private func doubles(from data: [OpenReportResponse.ReportData]?) -> [Double] {
        guard let data else { return [] }
        return data.map { $0.value }
    }

    private func thisMonth() -> QueryDate {
        let current = Date()
        let month = Calendar.current.component(.month, from: current)
        let year = Calendar.current.component(.year, from: current)
        let queryDate = QueryDate(year: year, month: month, day: nil)
        return queryDate
    }
}

private extension Array where Element == OpenReportResponse {
    func todayValue(for key: ReportVariable) -> Double? {
        today(for: key)?.value
    }
}
