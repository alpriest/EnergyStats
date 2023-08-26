//
//  ParameterGraphVariableChooserViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/05/2023.
//

import SwiftUI

class ParameterGraphVariableChooserViewModel: ObservableObject {
    @Published var variables: [ParameterGraphVariable] = []
    private let onApply: ([ParameterGraphVariable]) -> Void
    private let haptic = UIImpactFeedbackGenerator()

    init(variables: [ParameterGraphVariable], onApply: @escaping ([ParameterGraphVariable]) -> Void) {
        self.variables = variables.sorted(by: { $0.type.name.lowercased() < $1.type.name.lowercased() })
        self.onApply = onApply
        haptic.prepare()
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

    static let DefaultGraphVariables = ["generationPower",
                                        "batChargePower",
                                        "batDischargePower",
                                        "feedinPower",
                                        "gridConsumptionPower"]

    func chooseDefaultVariables() {
        select(just: Self.DefaultGraphVariables)
    }

    func chooseCompareStringsVariables() {
        select(just: ["pvPower",
                      "pv1Power",
                      "pv2Power",
                      "pv3Power",
                      "pv4Power"])
    }

    func chooseTemperatureVariables() {
        select(just: ["ambientTemperation",
                      "invTemperation",
                      "batTemperature"])
    }

    func chooseBatteryVariables() {
        select(just: ["batTemperature",
                      "batVolt",
                      "batCurrent",
                      "SoC"])
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
