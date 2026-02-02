//
//  ParameterVariableGroupEditorViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2023.
//

import Energy_Stats_Core
import Foundation

struct ParameterVariableGroupEditorViewData: Copiable {
    var groups: [ParameterGroup]
    var variables: [ParameterGraphVariable]
    var selected: UUID?

    func create(copying previous: ParameterVariableGroupEditorViewData) -> ParameterVariableGroupEditorViewData {
        .init(groups: previous.groups, variables: previous.variables, selected: previous.selected)
    }
}

class ParameterVariableGroupEditorViewModel: ObservableObject, ViewDataProviding {
    typealias ViewData = ParameterVariableGroupEditorViewData
    
    @Published var viewData: ViewData {
        didSet {
            if oldValue.selected != viewData.selected {
                updateVariables(for: viewData.groups.first { $0.id == viewData.selected })
            }
            isDirty = originalValue != viewData
        }
    }
    
    var selectedGroup: ParameterGroup? {
        viewData.groups.first { $0.id == viewData.selected }
    }
    
    private let rawVariables: [Variable]
    private var configManager: ConfigManaging
    @Published var isDirty = false
    var originalValue: ParameterVariableGroupEditorViewData?

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        let groups = configManager.parameterGroups
        self.rawVariables = configManager.variables
        let viewData = ViewData(
            groups: groups,
            variables: Self.variables(for: groups.first, from: configManager.variables),
            selected: groups.first?.id
        )
        self.originalValue = viewData
        self.viewData = viewData
    }

    func toggle(_ updating: ParameterGraphVariable) {
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
        guard let selectedGroup else { return }

        viewData = viewData.copy {
            $0.groups = viewData.groups.map { existingGroup in
                if existingGroup.title == selectedGroup.title {
                    return ParameterGroup(id: selectedGroup.id, title: selectedGroup.title, parameterNames: viewData.variables.filter { $0.isSelected }.map { $0.type.variable })
                } else {
                    return existingGroup
                }
            }
        }
        configManager.parameterGroups = viewData.groups
    }

    func update(_ title: String) {
        guard let selectedGroup else { return }

        viewData = viewData.copy {
            $0.groups = viewData.groups.map { existingGroup in
                if existingGroup.id == viewData.selected {
                    return ParameterGroup(id: selectedGroup.id, title: title, parameterNames: selectedGroup.parameterNames)
                } else {
                    return existingGroup
                }
            }
        }
    }

    func create(_ title: String) {
        let newGroupId = UUID()
        viewData = viewData.copy {
            $0.groups = viewData.groups + [
                ParameterGroup(id: newGroupId,
                               title: title,
                               parameterNames: viewData.variables.filter { $0.isSelected}.map { $0.type.variable})
            ]
            $0.selected = newGroupId
        }
        configManager.parameterGroups = viewData.groups
    }

    func delete() {
        guard let selectedGroup else { return }

        let updatedGroups: [ParameterGroup] = viewData.groups.compactMap { existingGroup in
            if existingGroup.title == selectedGroup.title {
                return nil
            } else {
                return existingGroup
            }
        }
        
        viewData = viewData.copy {
            $0.groups = updatedGroups
            $0.selected = updatedGroups.first?.id
        }
        configManager.parameterGroups = viewData.groups
    }
    
    private static func variables(for group: ParameterGroup?, from rawVariables: [Variable]) -> [ParameterGraphVariable] {
        guard let group else { return [] }
        
        return rawVariables.map { rawVariable in
            ParameterGraphVariable(rawVariable, isSelected: group.parameterNames.contains(rawVariable.variable))
        }.sorted(by: { $0.type.name.lowercased() < $1.type.name.lowercased() })
    }

    private func updateVariables(for group: ParameterGroup?) {
        guard let group else { return }

        viewData = viewData.copy {
            $0.variables = Self.variables(for: group, from: rawVariables)
        }
    }
}
