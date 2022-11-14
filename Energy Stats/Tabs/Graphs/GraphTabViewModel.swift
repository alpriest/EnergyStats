//
//  GraphTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation
import SwiftUI

struct GraphVariable: Identifiable, Equatable, Hashable {
    let type: RawVariable
    var enabled = true
    var id: String { type.title }

    init(_ type: RawVariable, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
    }
}

struct ValuesAtTime {
    let values: [GraphValue]
}

class GraphTabViewModel: ObservableObject {
    private var networking: Networking
    private var rawData: [GraphValue] = [] {
        didSet {
            data = rawData
        }
    }

    private var totals: [ReportVariable: Double] = [:]
    private let dateProvider: () -> Date

    @Published private(set) var stride = 1
    @Published private(set) var data: [GraphValue] = []
    @Published private(set) var graphVariables: [GraphVariable] = [GraphVariable(.generationPower), GraphVariable(.feedinPower), GraphVariable(.batChargePower), GraphVariable(.batDischargePower), GraphVariable(.gridConsumptionPower)]
    @Published var hours = 6 { didSet {
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

    init(_ networking: Networking, _ dateProvider: @escaping () -> Date = { Date() }) {
        self.networking = networking
        self.dateProvider = dateProvider
    }

    func start() async {
        do {
            let reportVariables = graphVariables.compactMap { $0.type.reportVariable }
            let reports = try await networking.fetchReport(variables: reportVariables)
            reports.forEach {
                guard let variable = ReportVariable(rawValue: $0.variable) else { return }

                totals[variable] = 0
                totals[variable] = $0.data.map { abs($0.value) }.reduce(0.0, +)
            }

            let raw = try await networking.fetchRaw(variables: graphVariables.map { $0.type })
            let rawData: [GraphValue] = raw.flatMap { reportVariable in
                reportVariable.data.compactMap {
                    guard let variable = RawVariable(rawValue: reportVariable.variable) else { return nil }
                    return GraphValue(date: $0.time, value: $0.value, variable: variable)
                }
            }

            await MainActor.run {
                self.errorMessage = nil
                self.rawData = rawData
                self.refresh()
            }
        } catch {
            self.errorMessage = "Could not load, check your connection"
        }
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type }
        let oldest = dateProvider().addingTimeInterval(0 - (3600 * Double(hours)))

        data = rawData
            .filter { $0.date > oldest }
            .filter { !hiddenVariableTypes.contains($0.variable) }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })
    }

    func total(of type: RawVariable) -> Double? {
        guard let reportVariable = type.reportVariable else { return nil }
        guard totals.keys.contains(reportVariable) else { return nil }

        return totals[reportVariable]
    }

    func data(at date: Date) -> ValuesAtTime {
        let visibleVariableTypes = graphVariables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.variable) })
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

struct GraphValue: Identifiable {
    let date: Date
    let value: Double
    let variable: RawVariable

    var id: String { "\(date.iso8601())_\(variable.title)" }

    init(date: Date, value: Double, variable: RawVariable) {
        self.date = date
        self.value = value
        self.variable = variable
    }
}

private extension Double {
    func floored(_ variable: RawVariable) -> Double {
        max(0, self)
    }
}
