//
//  ParameterGraphVariableChooserViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/05/2023.
//

import Energy_Stats_Core
import SwiftUI

class ParameterGraphVariableChooserViewModel: ObservableObject {
    @Published var variables: [ParameterGraphVariable] = [] { didSet { determineSelectedGroup() }}
    private let onApply: ([ParameterGraphVariable]) -> Void
    private let haptic = UIImpactFeedbackGenerator()
    private(set) var configManager: ConfigManaging
    @Published var groups: [ParameterGroup]
    @Published var selected: UUID?
    @Published var truncatedYAxis: Bool {
        didSet {
            configManager.truncatedYAxisOnParameterGraphs = truncatedYAxis
        }
    }

    init(variables: [ParameterGraphVariable], configManager: ConfigManaging, onApply: @escaping ([ParameterGraphVariable]) -> Void) {
        self.variables = variables.sorted(by: { $0.type.name.lowercased() < $1.type.name.lowercased() })
        self.configManager = configManager
        self.onApply = onApply
        self.groups = configManager.parameterGroups
        self.truncatedYAxis = configManager.truncatedYAxisOnParameterGraphs
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

    static let DefaultGraphVariables = ["invBatPower",
                                        "meterPower",
                                        "loadsPower",
                                        "pvPower",
                                        "SoC"]

    func chooseDefaultVariables() {
        select(just: Self.DefaultGraphVariables)
    }

    func select(_ group: ParameterGroup) {
        select(just: group.parameterNames)
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

    private func determineSelectedGroup() {
        selected = groups.first(where: { group -> Bool in
            group.parameterNames.sorted() == variables.filter { $0.isSelected }.map { $0.type.variable }.sorted()
        })?.id
    }
}
