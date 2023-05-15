//
//  StatsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Energy_Stats_Core
import Foundation

class StatsTabViewModel: ObservableObject {
    private let networking: Networking
    private let configManager: ConfigManaging

    @Published var state = LoadState.inactive
    @Published var displayMode: StatsDisplayMode = .day(.now) {
        didSet {
            Task { @MainActor in
                await load()
            }
        }
    }

    var stride: Int = 3
    var data: [GraphValue] = []

    init(networking: Networking, configManager: ConfigManaging) {
        self.networking = networking
        self.configManager = configManager
    }

    func data(at date: Date) -> ValuesAtTime {
        ValuesAtTime(values: [])
    }

    func load() async {
        print("AWP", "load")
        guard let currentDevice = configManager.currentDevice.value else { return }

        let reportVariables: [ReportVariable] = [.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption]
        let queryDate = makeQueryDate()
        let reportType = makeReportType()

        do {
            let reports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate, reportType: reportType)

        } catch {
            await MainActor.run {
                self.state = .error(error, "Could not load, check your connection")
            }
        }
//        rawGraphVariables.forEach { rawVariable in
//            guard let reportVariable = rawVariable.reportVariable else { return }
//            guard let response = reports.first(where: { $0.variable.lowercased() == reportVariable.networkTitle.lowercased() }) else { return }
//
//            totals[reportVariable] = 0
//            totals[reportVariable] = response.data.map { abs($0.value) }.reduce(0.0, +)
//        }
    }
}

private extension StatsTabViewModel {
    func makeQueryDate() -> QueryDate {
        switch displayMode {
        case .day(let date):
            return QueryDate(year: Calendar.current.component(.year, from: date),
                             month: Calendar.current.component(.month, from: date),
                             day: Calendar.current.component(.day, from: date))
        case .month(let month, let year):
            return QueryDate(year: year, month: month, day: nil)
        case .year(let year):
            return QueryDate(year: year, month: nil, day: nil)
        }
    }

    func makeReportType() -> ReportType {
        switch displayMode {
        case .day:
            return .day
        case .month:
            return .month
        case .year:
            return .year
        }
    }
}
