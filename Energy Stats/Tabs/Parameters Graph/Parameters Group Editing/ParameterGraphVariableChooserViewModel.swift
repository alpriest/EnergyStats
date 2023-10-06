//
//  ParameterGraphVariableChooserViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/05/2023.
//

import SwiftUI
import Energy_Stats_Core

class ParameterGraphVariableChooserViewModel: ObservableObject {
    @Published var variables: [ParameterGraphVariable] = []
    private let onApply: ([ParameterGraphVariable]) -> Void
    private let haptic = ImpactHapticGenerator()
    private(set) var configManager: ConfigManaging
    @Published var groups: [ParameterGroup]

    init(variables: [ParameterGraphVariable], configManager: ConfigManaging, onApply: @escaping ([ParameterGraphVariable]) -> Void) {
        self.variables = variables.sorted(by: { $0.type.name.lowercased() < $1.type.name.lowercased() })
        self.configManager = configManager
        self.onApply = onApply
        self.groups = configManager.parameterGroups
    }

    func toggle(updating: ParameterGraphVariable) {
        variables = variables.map { existingVariable in
            var existingVariable = existingVariable

            if existingVariable.type.name == updating.type.name {
                existingVariable.setSelected(!updating.isSelected)
            }

            return existingVariable
        }
    }

    func apply() {
        onApply(variables)
    }

    func createGroup(named name: String) {
        groups.append(ParameterGroup(id: UUID(), title: name, parameterNames: variables.filter { $0.isSelected }.map { $0.type.variable }))
        configManager.parameterGroups = groups
    }

    func delete(at index: Int) {
        groups.remove(at: index)
        configManager.parameterGroups = groups
    }

    static let DefaultGraphVariables = ["generationPower",
                                        "batChargePower",
                                        "batDischargePower",
                                        "feedinPower",
                                        "gridConsumptionPower"]

    func chooseDefaultVariables() {
        select(just: Self.DefaultGraphVariables)
    }

    func select(just newVariables: [String]) {
        variables = variables.map { existingVariable in
            var existingVariable = existingVariable
            if newVariables.contains(existingVariable.type.variable) {
                existingVariable.setSelected(true)
            } else {
                existingVariable.setSelected(false)
            }
            return existingVariable
        }

        haptic.impactOccurred()
    }
}
