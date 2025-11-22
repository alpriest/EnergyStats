//
//  ParameterGraphVariableChooserViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/05/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ParameterGraphVariableChooserViewData: Copiable {
    var groups: [ParameterGroup]
    var variables: [ParameterGraphVariable]
    var selected: UUID?

    func create(copying previous: ParameterGraphVariableChooserViewData) -> ParameterGraphVariableChooserViewData {
        .init(
            groups: previous.groups,
            variables: previous.variables,
            selected: previous.selected
        )
    }
}

class ParameterGraphVariableChooserViewModel: ObservableObject {
    private let onApply: ([ParameterGraphVariable]) -> Void
    private let haptic = UIImpactFeedbackGenerator()
    private(set) var configManager: ConfigManaging
    @Published var viewData: ParameterGraphVariableChooserViewData { didSet {
        isDirty = originalValue != viewData
    }}
    private var originalValue: ParameterGraphVariableChooserViewData?
    @Published var isDirty = false

    init(variables: [ParameterGraphVariable], configManager: ConfigManaging, onApply: @escaping ([ParameterGraphVariable]) -> Void) {
        let viewData = ParameterGraphVariableChooserViewData(
            groups: configManager.parameterGroups,
            variables: variables.sorted(by: { $0.type.name.lowercased() < $1.type.name.lowercased() }),
            selected: nil
        )
        originalValue = viewData
        self.viewData = viewData

        self.configManager = configManager
        self.onApply = onApply
        haptic.prepare()
    }

    func toggle(updating: ParameterGraphVariable) {
        viewData = viewData.copy {
            $0.variables = viewData.variables.map { existingVariable in
                var existingVariable = existingVariable

                if existingVariable.type.name == updating.type.name {
                    existingVariable.setSelected(!updating.isSelected)
                }

                return existingVariable
            }
        }
    }

    func apply() {
        onApply(viewData.variables)
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
        viewData = viewData.copy {
            $0.variables = viewData.variables.map { existingVariable in
                var existingVariable = existingVariable
                if newVariables.contains(existingVariable.type.variable) {
                    existingVariable.setSelected(true)
                } else {
                    existingVariable.setSelected(false)
                }
                return existingVariable
            }
        }

        haptic.impactOccurred()
    }

    private func determineSelectedGroup() {
        viewData = viewData.copy {
            $0.selected = viewData.groups.first(where: { group -> Bool in
                group.parameterNames.sorted() == viewData.variables.filter { $0.isSelected }.map { $0.type.variable }.sorted()
            })?.id
        }
    }
}
