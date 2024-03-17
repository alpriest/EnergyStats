//
//  StatsDataFetcher.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/03/2024.
//

import Energy_Stats_Core
import Foundation

struct StatsDataFetcher {
    let networking: Networking
    let approximationsCalculator: ApproximationsCalculator

    func fetchCustomData(
        device: Device,
        start: Date,
        end: Date,
        reportVariables: [ReportVariable],
        approximationsCalculator: ApproximationsCalculator,
        displayMode: StatsDisplayMode
    ) async throws -> ([StatsGraphValue], [ReportVariable: Double]) {
        var current = start
        var accumulatedGraphValues: [StatsGraphValue] = []
        var accumulatedReportResponses: [OpenReportResponse] = []

        while current.month <= end.month {
            print("Fetch data for \(current)")

            let startMonth = Calendar.current.component(.month, from: current)
            let startYear = Calendar.current.component(.year, from: current)
            let startQueryDate = QueryDate(year: startYear, month: startMonth, day: nil)
            let startReports = try await networking.fetchReport(
                deviceSN: device.deviceSN,
                variables: reportVariables,
                queryDate: startQueryDate,
                reportType: .month
            ).map { response in
                response.copy(values: response.values.filter {
                    let components = DateComponents(year: startYear, month: startMonth, day: $0.index + 1)
                    guard let dataDate = Calendar.current.date(from: components) else { return false }

                    return dataDate >= start && dataDate <= end
                })
            }
            let startData = startReports.flatMap { reportResponse -> [StatsGraphValue] in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return [] }

                return reportResponse.values.map { dataPoint in
                    let graphPointDate = Calendar.current.date(from: DateComponents(year: startYear, month: startMonth, day: dataPoint.index, hour: 0))!

                    return StatsGraphValue(
                        date: graphPointDate, value: dataPoint.value, type: reportVariable
                    )
                }
            }

            accumulatedReportResponses.append(contentsOf: startReports)
            accumulatedGraphValues.append(contentsOf: startData)

            if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: current) {
                current = nextMonth
            } else {
                break // Break the loop if unable to find the next month
            }
        }

        let totals = try await approximationsCalculator.generateTotals(
            currentDevice: device,
            reportType: .month,
            reports: accumulatedReportResponses,
            reportVariables: reportVariables
        )

        return (accumulatedGraphValues, totals)
    }

    func fetchData(
        device: Device,
        reportVariables: [ReportVariable],
        approximationsCalculator: ApproximationsCalculator,
        displayMode: StatsDisplayMode
    ) async throws -> ([StatsGraphValue], [ReportVariable: Double]) {
        let queryDate = makeQueryDate(displayMode: displayMode)
        let reportType = makeReportType(displayMode: displayMode)
        let reports = try await networking.fetchReport(
            deviceSN: device.deviceSN,
            variables: reportVariables,
            queryDate: queryDate,
            reportType: reportType
        )
        let totals = try await approximationsCalculator.generateTotals(
            currentDevice: device,
            reportType: reportType,
            queryDate: queryDate,
            reports: reports,
            reportVariables: reportVariables
        )

        let updatedData = reports.flatMap { reportResponse -> [StatsGraphValue] in
            guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return [] }

            return reportResponse.values.map { dataPoint in
                var graphPointDate = Date.yesterday()

                switch displayMode {
                case .day(let date):
                    graphPointDate = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date),
                                                                                month: Calendar.current.component(.month, from: date),
                                                                                day: Calendar.current.component(.day, from: date),
                                                                                hour: dataPoint.index - 1, minute: 0))!
                case .month(let month, let year):
                    graphPointDate = Calendar.current.date(from: DateComponents(year: year, month: month + 1, day: dataPoint.index, hour: 0))!
                case .year(let year):
                    graphPointDate = Calendar.current.date(from: DateComponents(year: year, month: dataPoint.index, day: 1, hour: 0))!
                case .custom:
                    ()
                }

                return StatsGraphValue(
                    date: graphPointDate, value: dataPoint.value, type: reportVariable
                )
            }
        }

        return (updatedData, totals)
    }

    private func makeReportType(displayMode: StatsDisplayMode) -> ReportType {
        switch displayMode {
        case .day:
            return .day
        case .month:
            return .month
        case .year:
            return .year
        case .custom:
            return .month
        }
    }

    private func makeQueryDate(displayMode: StatsDisplayMode) -> QueryDate {
        switch displayMode {
        case .day(let date):
            return QueryDate(year: Calendar.current.component(.year, from: date),
                             month: Calendar.current.component(.month, from: date),
                             day: Calendar.current.component(.day, from: date))
        case .month(let month, let year):
            return QueryDate(year: year, month: month + 1, day: nil)
        case .year(let year):
            return QueryDate(year: year, month: nil, day: nil)
        case .custom:
            return QueryDate(from: Date.now)
        }
    }
}
