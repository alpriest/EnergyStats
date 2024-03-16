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
        let startDay = Calendar.current.component(.day, from: start)
        let startMonth = Calendar.current.component(.month, from: start)
        let startYear = Calendar.current.component(.year, from: start)
        let startQueryDate = QueryDate(year: startYear, month: startMonth, day: nil)
        let startReports = try await networking.fetchReport(
            deviceSN: device.deviceSN,
            variables: reportVariables,
            queryDate: startQueryDate,
            reportType: .month
        ).map { response in
            response.copy(values: response.values.filter {
                $0.index >= startDay
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

        let endDay = Calendar.current.component(.day, from: end)
        let endMonth = Calendar.current.component(.month, from: end)
        let endYear = Calendar.current.component(.year, from: end)
        let endQueryDate = QueryDate(year: endYear, month: endMonth, day: nil)
        let endReports = try await networking.fetchReport(
            deviceSN: device.deviceSN,
            variables: reportVariables,
            queryDate: endQueryDate,
            reportType: .month
        ).map { response in
            response.copy(values: response.values.filter {
                $0.index <= endDay
            })
        }
        let endData = endReports.flatMap { reportResponse -> [StatsGraphValue] in
            guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return [] }

            return reportResponse.values.map { dataPoint in
                let graphPointDate = Calendar.current.date(from: DateComponents(year: endYear, month: endMonth, day: dataPoint.index, hour: 0))!

                return StatsGraphValue(
                    date: graphPointDate, value: dataPoint.value, type: reportVariable
                )
            }
        }

        let totals = try await approximationsCalculator.generateTotals(
            currentDevice: device,
            reportType: .month,
            queryDate: startQueryDate,
            reports: startReports + endReports,
            reportVariables: reportVariables
        )

        return (startData + endData, totals)
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
