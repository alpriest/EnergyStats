//
//  StatsLoadCoordinator.swift
//  Energy Stats
//

import Energy_Stats_Core
import Foundation

struct StatsLoadResult {
    let reportData: [StatsGraphValue]
    let totals: [ReportVariable: Double]
    let batterySOCData: [StatsGraphValue]
}

struct StatsLoadCoordinator {
    private let networking: Networking
    private let fetcher: StatsDataFetcher

    init(networking: Networking, approximationsCalculator: ApproximationsCalculator) {
        self.networking = networking
        self.fetcher = StatsDataFetcher(
            networking: networking,
            approximationsCalculator: approximationsCalculator
        )
    }

    func load(
        device: Device,
        displayMode: StatsGraphDisplayMode,
        reportVariables: [ReportVariable],
        includeBatterySOC: Bool
    ) async throws -> StatsLoadResult {
        let reportResult: ([StatsGraphValue], [ReportVariable: Double])

        if case .custom(let start, let end, let unit) = displayMode {
            reportResult = try await fetcher.fetchCustomDateRangeData(
                device: device,
                start: start,
                end: end,
                reportVariables: reportVariables,
                unit: unit
            )
        } else {
            reportResult = try await fetcher.fetchData(
                device: device,
                reportVariables: reportVariables,
                displayMode: displayMode
            )
        }

        let batterySOCData = try await fetchBatterySOC(
            for: device,
            displayMode: displayMode,
            includeBatterySOC: includeBatterySOC
        )

        return StatsLoadResult(
            reportData: reportResult.0,
            totals: reportResult.1,
            batterySOCData: batterySOCData
        )
    }

    private func fetchBatterySOC(
        for device: Device,
        displayMode: StatsGraphDisplayMode,
        includeBatterySOC: Bool
    ) async throws -> [StatsGraphValue] {
        guard includeBatterySOC else { return [] }

        let socData: [StatsGraphValue]

        switch displayMode {
        case .day(let date):
            let startDate = Calendar.current.startOfDay(for: date)
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
            let responseData = try await networking.fetchHistory(
                deviceSN: device.deviceSN,
                variables: ["SoC"],
                start: startDate,
                end: endDate
            )
            let rawSOCData = responseData.datas.flatMap { $0.data }

            socData = rawSOCData
                .map { unitData in
                    StatsGraphValue(
                        type: .batterySOC,
                        date: unitData.time,
                        graphValue: unitData.value,
                        displayValue: unitData.value / 100.0
                    )
                }
                .sorted(by: { $0.date < $1.date })
                .filter { $0.date <= Date.now }
        default:
            socData = []
        }

        return socData
    }
}
