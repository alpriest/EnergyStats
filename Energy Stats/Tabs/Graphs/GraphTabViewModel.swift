//
//  GraphTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Foundation
import SwiftUI

struct GraphVariable: Identifiable, Equatable {
    let type: VariableType
    var enabled = true
    var id: String { type.title }

    init(_ type: VariableType, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
    }
}

class GraphTabViewModel: ObservableObject {
    private var networking: Networking
    private var rawData: [GraphValue] = [] {
        didSet {
            data = rawData
        }
    }
    private var totals: [VariableType: Double] = [:]

    @Published var data: [GraphValue] = []
    @Published var variables: [GraphVariable] = [GraphVariable(.feedinPower), GraphVariable(.gridConsumptionPower), GraphVariable(.generationPower), GraphVariable(.batChargePower), GraphVariable(.pvPower)]

    init(_ networking: Networking) {
        self.networking = networking
    }

    func start() {
        Task {
            let raw = try await networking.fetchRaw(variables: variables.map { $0.type })
            let report = try await networking.fetchReport(variables: variables.map { $0.type })

            let data: [GraphValue] = raw.result.flatMap { reportVariable in
                reportVariable.data.compactMap {
                    guard let variable = VariableType(rawValue: reportVariable.variable) else { return nil }
                    return GraphValue(date: $0.time, value: $0.value, variable: variable)
                }
            }

            report.result.forEach {
                guard let variable = VariableType(fromReport: $0.variable) else { return }

                totals[variable] = $0.data.map { abs($0.value) }.reduce(0.0, +)
            }

            await MainActor.run { self.rawData = data }
        }
    }

    func refresh() {
        let hiddenVariables = variables.filter { $0.enabled == false }.map { $0.type }
        data = rawData.filter { !hiddenVariables.contains($0.variable) }
    }

    func total(of type: VariableType) -> Double? {
        guard totals.keys.contains(type) else { return nil }

        return totals[type]
    }
}

struct GraphValue: Identifiable {
    let date: Date
    let value: Double
    let variable: VariableType

    var id: Date { date }
}
