//
//  ParameterVariableGroupEditorViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2023.
//

import Energy_Stats_Core
import Foundation

class ParameterVariableGroupEditorViewModel: ObservableObject {
    @Published var selected: UUID? {
        didSet {
            updateVariables(for: groups.first { $0.id == selected })
        }
    }

    var selectedGroup: ParameterGroup? {
        groups.first { $0.id == selected }
    }

    @Published var groups: [ParameterGroup]
    @Published var variables: [ParameterGraphVariable] = []
    private let rawVariables: [Variable]
    private var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        self.groups = configManager.parameterGroups
        self.rawVariables = configManager.variables
        self.selected = groups.first?.id
        updateVariables(for: groups.first)
    }

    func toggle(_ updating: ParameterGraphVariable) {
        variables = variables.map { existingVariable in
            var existingVariable = existingVariable

            if existingVariable.type.name == updating.type.name {
                existingVariable.setSelected(!updating.isSelected)
            }

            return existingVariable
        }
    }

    func apply() {
        guard let selectedGroup else { return }

        groups = groups.map { existingGroup in
            if existingGroup.title == selectedGroup.title {
                return ParameterGroup(id: selectedGroup.id, title: selectedGroup.title, parameterNames: variables.filter { $0.isSelected }.map { $0.type.variable })
            } else {
                return existingGroup
            }
        }
        configManager.parameterGroups = groups
    }

    func update(_ title: String) {
        guard let selectedGroup else { return }

        groups = groups.map { existingGroup in
            if existingGroup.id == selected {
                return ParameterGroup(id: selectedGroup.id, title: title, parameterNames: selectedGroup.parameterNames)
            } else {
                return existingGroup
            }
        }
    }

    func create(_ title: String) {
        let newGroupId = UUID()
        groups = groups + [
            ParameterGroup(id: newGroupId,
                           title: title,
                           parameterNames: variables.filter { $0.isSelected}.map { $0.type.variable})
        ]
        configManager.parameterGroups = groups
        selected = newGroupId
    }

    func delete() {
        guard let selectedGroup else { return }

        groups = groups.compactMap { existingGroup in
            if existingGroup.title == selectedGroup.title {
                return nil
            } else {
                return existingGroup
            }
        }
        configManager.parameterGroups = groups
        selected = groups.first?.id
    }

    private func updateVariables(for group: ParameterGroup?) {
        guard let group else { return }

        variables = rawVariables.map { rawVariable in
            ParameterGraphVariable(rawVariable, isSelected: group.parameterNames.contains(rawVariable.variable))
        }.sorted(by: { $0.type.name.lowercased() < $1.type.name.lowercased() })
    }
}
