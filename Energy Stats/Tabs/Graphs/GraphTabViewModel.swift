//
//  GraphTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation
import SwiftUI

struct GraphVariable: Identifiable, Equatable, Hashable {
    let type: VariableType
    var enabled = true
    var id: String { type.title }

    init(_ type: VariableType, enabled: Bool = true) {
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

    private var totals: [VariableType: Double] = [:]

    @Published var stride = 1
    @Published var data: [GraphValue] = []
    @Published var variables: [GraphVariable] = [GraphVariable(.feedinPower), GraphVariable(.gridConsumptionPower), GraphVariable(.generationPower), GraphVariable(.batChargePower), GraphVariable(.pvPower)]
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

    init(_ networking: Networking) {
        self.networking = networking
    }

    func start() {
        Task {
            let reports = try await networking.fetchReport(variables: variables.map { $0.type })
            reports.forEach {
                guard let variable = VariableType(fromReport: $0.variable) else { return }

                totals[variable] = $0.data.map { abs($0.value) }.reduce(0.0, +)
            }

            let raw = try await networking.fetchRaw(variables: variables.map { $0.type })
            let rawData: [GraphValue] = raw.flatMap { reportVariable in
                reportVariable.data.compactMap {
                    guard let variable = VariableType(rawValue: reportVariable.variable) else { return nil }
                    return GraphValue(date: $0.time, value: $0.value, variable: variable)
                }
            }

            await MainActor.run {
                self.rawData = rawData
                self.refresh()
            }
        }
    }

    func refresh() {
        let hiddenVariableTypes = variables.filter { $0.enabled == false }.map { $0.type }
        let oldest = Date().addingTimeInterval(0 - (3600 * Double(hours)))

        data = rawData
            .filter { $0.date > oldest }
            .filter { !hiddenVariableTypes.contains($0.variable) }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })
    }

    func total(of type: VariableType) -> Double? {
        guard totals.keys.contains(type) else { return nil }

        return totals[type]
    }

    func data(at date: Date) -> ValuesAtTime? {
        let visibleVariableTypes = variables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.variable) })
        return result
    }

    func toggle(visibilityOf variable: GraphVariable) {
        variables = variables.map {
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
    let variable: VariableType

    var id: String { "\(date.iso8601())_\(variable.title)" }

    init(date: Date, value: Double, variable: VariableType) {
        self.date = date
        self.value = value.floored(variable)
        self.variable = variable
    }
}

private extension Double {
    func floored(_ variable: VariableType) -> Double {
        guard variable == .pvPower else { return self }

        return max(0, self)
    }
}
