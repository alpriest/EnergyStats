//
//  ParameterGraphVariableChooserView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/05/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ParameterGraphVariableChooserView: View {
    @ObservedObject var viewModel: ParameterGraphVariableChooserViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var editMode = EditMode.inactive
    @State private var groupName = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section {
                        List {
                            Button("Default") { viewModel.chooseDefaultVariables() }

                            ForEach(viewModel.groups, id: \.title) { group in
                                Button(group.title) { viewModel.select(just: group.parameterNames) }
                            }

                            Button("None") { viewModel.select(just: []) }
                        }

                    } header: {
                        Text("Groups")
                    }

                    if editMode.isEditing {
                        Section {
                            TextField("Group name", text: $groupName)
                            Button("Create") {
                                viewModel.createGroup(named: groupName)
                                editMode = .inactive
                                groupName = ""
                            }.contentShape(Rectangle())
                        } header: {
                            Text("Create")
                        } footer: {
                            Text("This will create a new group from your selected parameters.")
                        }
                    }

                    Section {
                        ParameterVariableListView(variables: viewModel.variables, onTap: viewModel.toggle)
                    } header: {
                        Text("Parameters")
                    } footer: {
                        Link(destination: URL(string: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/Fox-ESS-Cloud#search-parameters")!) {
                            HStack {
                                Text("Find out more about these variables")
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .font(.caption)
                        }

                        Button("Restore defaults") {}
                            .buttonStyle(.borderedProminent)
                    }
                }

                BottomButtonsView {
                    viewModel.apply()
                    dismiss()
                } onCancel: {
                    dismiss()
                } footer: {
                    Text("Note that not all parameters contain values")
                }
            }
            .navigationTitle("Parameter Groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: { ParameterVariableGroupEditorView(viewModel: ParameterVariableGroupEditorViewModel(configManager: viewModel.configManager)) },
                               label: { Text("Edit") })
            } }
        }
    }

    private var isEditing: Bool {
        editMode.isEditing == true
    }
}

#Preview {
    let variables = RawVariable.previewList().map { ParameterGraphVariable($0, isSelected: [true, false].randomElement()!) }

    return ParameterGraphVariableChooserView(
        viewModel: ParameterGraphVariableChooserViewModel(variables: variables,
                                                          configManager: PreviewConfigManager(),
                                                          onApply: { _ in }))
}

extension RawVariable {
    static func previewList() -> [RawVariable] {
        [RawVariable(name: "PV1Volt", variable: "pv1Volt", unit: "V"),
         RawVariable(name: "PV1Current", variable: "pv1Current", unit: "A"),
         RawVariable(name: "PV1Power", variable: "pv1Power", unit: "kW"),
         RawVariable(name: "PVPower", variable: "pvPower", unit: "kW"),
         RawVariable(name: "PV2Volt", variable: "pv2Volt", unit: "V"),
         RawVariable(name: "PV2Current", variable: "pv2Current", unit: "A"),
         RawVariable(name: "generationPower", variable: "generationPower", unit: "A"),
         RawVariable(name: "batChargePower", variable: "batChargePower", unit: "kW"),
         RawVariable(name: "batDischargePower", variable: "batDischargePower", unit: "kW"),
         RawVariable(name: "feedinPower", variable: "feedinPower", unit: "V"),
         RawVariable(name: "gridConsumptionPower", variable: "gridConsumptionPower", unit: "A"),
         RawVariable(name: "bPV1Current", variable: "pv1Current", unit: "A"),
         RawVariable(name: "bPV1Power", variable: "pv1Power", unit: "kW"),
         RawVariable(name: "bPVPower", variable: "pvPower", unit: "kW"),
         RawVariable(name: "bPV2Volt", variable: "pv2Volt", unit: "V"),
         RawVariable(name: "batTemperature", variable: "batTemperature", unit: "A"),
         RawVariable(name: "batVolt", variable: "batVolt", unit: "A"),
         RawVariable(name: "batCurrent", variable: "batCurrent", unit: "kW"),
         RawVariable(name: "SoC", variable: "SoC", unit: "kW"),
         RawVariable(name: "cPV2Volt", variable: "pv2Volt", unit: "V"),
         RawVariable(name: "dPV2Current", variable: "pv2Current", unit: "A"),
         RawVariable(name: "dPV2Power", variable: "pv2Power", unit: "kW")]
    }
}
