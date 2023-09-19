//
//  ParameterVariableGroupEditorView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2023.
//

import Energy_Stats_Core
import SwiftUI

class ParameterVariableGroupEditorViewModel: ObservableObject {
    @Published var selected: ParameterGroup {
        didSet {
            variables = rawVariables.map({ rawVariable in
                ParameterGraphVariable(rawVariable, isSelected: selected.parameterNames.contains(rawVariable.variable))
            })
        }
    }
    let groups: [ParameterGroup]
    @Published var variables: [ParameterGraphVariable] = []
    private let rawVariables: [RawVariable]

    init(groups: [ParameterGroup], rawVariables: [RawVariable]) {
        self.groups = groups
        self.rawVariables = rawVariables
        selected = groups.first ?? ParameterGroup(title: "Default", parameterNames: ParameterGraphVariableChooserViewModel.DefaultGraphVariables)
    }

    func toggle(_ variable: ParameterGraphVariable) {}
}

struct ParameterVariableGroupEditorView: View {
    @ObservedObject var viewModel: ParameterVariableGroupEditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Picker("Group", selection: $viewModel.selected) {
                        ForEach(viewModel.groups, id: \.self) { group in
                            Text(group.title)
                        }
                    }
                } header: {
                    Text("Choose group to edit")
                }

                Section {
                    ParameterVariableListView(variables: viewModel.variables, onTap: viewModel.toggle)
                } header: {
                    Text("Choose Parameters")
                }

//                Section {
//                    Button("Sort this group") {
//                        // TODO
//                    }
//
//                    Button(role: .destructive) {
//                        // TODO
//                    } label: {
//                        Text("Delete this group")
//                    }
//                }
            }

            BottomButtonsView {
                // TODO:
            }
        }
    }
}

#Preview {
    ParameterVariableGroupEditorView(
        viewModel: ParameterVariableGroupEditorViewModel(
            groups: [.init(title: "First", parameterNames: ["generationPower",
                                                            "batChargePower",
                                                            "batDischargePower",
                                                            "feedinPower",
                                                            "gridConsumptionPower"]),
                     .init(title: "Second", parameterNames: ["batTemperature",
                                                             "batVolt",
                                                             "batCurrent",
                                                             "SoC"])],
            rawVariables: RawVariable.previewList()
        )
    )
}
