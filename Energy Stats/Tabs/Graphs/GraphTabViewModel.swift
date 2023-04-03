//
//  GraphTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation
import SwiftUI
import Energy_Stats_Core

struct ValuesAtTime {
    let values: [GraphValue]
}

class GraphTabViewModel: ObservableObject {
    private let haptic = UIImpactFeedbackGenerator()
    private let networking: Networking
    private var rawData: [GraphValue] = [] {
        didSet {
            data = rawData
        }
    }

    private var totals: [ReportVariable: Double] = [:]
    private let dateProvider: () -> Date

    @Published private(set) var stride = 3
    @Published private(set) var data: [GraphValue] = []
    @Published private(set) var graphVariables: [GraphVariable] = [GraphVariable(.generationPower), GraphVariable(RawVariable.batChargePower), GraphVariable(.batDischargePower), GraphVariable(.feedinPower), GraphVariable(.gridConsumptionPower)]
    @Published var hours = 24 { didSet {
        switch hours {
        case 6:
            stride = 1
        case 12:
            stride = 2
        default:
            stride = 3
        }
        refresh()
    }}
    @Published private(set) var errorMessage: String? = nil
    private let configManager: ConfigManaging

    init(_ networking: Networking, configManager: ConfigManaging, _ dateProvider: @escaping () -> Date = { Date() }) {
        self.networking = networking
        self.configManager = configManager
        self.dateProvider = dateProvider
        haptic.prepare()
    }

    func start() async {
        guard let currentDevice = configManager.currentDevice else { return }

        do {
            let rawVariables = graphVariables.compactMap { $0.type }
            let reportVariables = rawVariables.compactMap { $0.reportVariable }
            let queryDate = QueryDate.current()

            let raw = try await networking.fetchRaw(deviceID: currentDevice.deviceID, variables: rawVariables)
            let rawData: [GraphValue] = raw.flatMap { response -> [GraphValue] in
                guard let rawVariable = RawVariable(rawValue: response.variable) else { return [] }

                return response.data.compactMap {
                    GraphValue(date: $0.time, queryDate: queryDate, value: $0.value, variable: rawVariable)
                }
            }

            let reports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate)
            rawVariables.forEach { rawVariable in
                guard let reportVariable = rawVariable.reportVariable else { return }
                guard let response = reports.first(where: { $0.variable == reportVariable.rawValue }) else { return }

                totals[reportVariable] = 0
                totals[reportVariable] = response.data.map { abs($0.value) }.reduce(0.0, +)
            }

            await MainActor.run {
                self.errorMessage = nil
                self.rawData = rawData
                self.refresh()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Could not load, check your connection"
            }
        }
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type }
        let oldest = dateProvider().addingTimeInterval(0 - (3600 * Double(hours)))

        let refreshedData = rawData
            .filter { !hiddenVariableTypes.contains($0.variable) }
            .filter { $0.date > oldest }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })

        max = refreshedData.max(by: { lhs, rhs in
            lhs.value < rhs.value
        })
        data = refreshedData
    }

    var max: GraphValue?

    func total(of type: ReportVariable?) -> Double? {
        guard let type = type else { return nil }
        guard totals.keys.contains(type) else { return nil }

        return totals[type]
    }

    func data(at date: Date) -> ValuesAtTime {
        let visibleVariableTypes = graphVariables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.variable) })

        if let maxDate = max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        return result
    }

    func toggle(visibilityOf variable: GraphVariable) {
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
}
