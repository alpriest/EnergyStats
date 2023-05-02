//
//  GraphVariableChooserViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/05/2023.
//

import SwiftUI

class GraphVariableChooserViewModel: ObservableObject {
    @Published var variables: [GraphVariable] = []
    private let onApply: ([GraphVariable]) -> Void
    private let haptic = UIImpactFeedbackGenerator()

    init(variables: [GraphVariable], onApply: @escaping ([GraphVariable]) -> Void) {
        self.variables = variables.sorted(by: { $0.type.name < $1.type.name })
        self.onApply = onApply
        haptic.prepare()
    }

    func toggle(updating: GraphVariable) {
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

    func chooseDefaultVariables() {
        select(just: GraphTabViewModel.DefaultGraphVariables)
    }

    func chooseCompareStringsVariables() {
        select(just: ["pv1Power",
                      "pv2Power",
                      "pv3Power",
                      "pv4Power"])
    }

    func chooseTemperatureVariables() {
        select(just: ["ambientTemperation",
                      "boostTemperation",
                      "invTemperation",
                      "chargeTemperature",
                      "batTemperature",
                      "dspTemperature"])
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
