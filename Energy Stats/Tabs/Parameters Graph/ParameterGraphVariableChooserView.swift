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

    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.delete(at: index)
        }
    }

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
                            .onDelete(perform: delete)

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
                        List(viewModel.variables) { variable in
                            Button {
                                viewModel.toggle(updating: variable)
                            } label: {
                                HStack {
                                    if variable.isSelected {
                                        Label(variable.type.name, systemImage: "checkmark.circle.fill")
                                    } else {
                                        Label(variable.type.name, systemImage: "circle")
                                    }

                                    Spacer()

                                    Text(variable.type.unit)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
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
                } footer: {
                    Text("Note that not all parameters contain values")
                }
            }
            .navigationTitle("Parameter Groups")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { EditButton() } }
//            .environment(\.editMode, self.$editMode)
        }
    }

    private var isEditing: Bool {
        editMode.isEditing == true
    }
}

struct VariableChooser_Previews: PreviewProvider {
    static var previews: some View {
        let variables = [RawVariable(name: "PV1Volt", variable: "pv1Volt", unit: "V"),
                         RawVariable(name: "PV1Current", variable: "pv1Current", unit: "A"),
                         RawVariable(name: "PV1Power", variable: "pv1Power", unit: "kW"),
                         RawVariable(name: "PVPower", variable: "pvPower", unit: "kW"),
                         RawVariable(name: "PV2Volt", variable: "pv2Volt", unit: "V"),
                         RawVariable(name: "PV2Current", variable: "pv2Current", unit: "A"),
                         RawVariable(name: "aPV1Current", variable: "pv1Current", unit: "A"),
                         RawVariable(name: "aPV1Power", variable: "pv1Power", unit: "kW"),
                         RawVariable(name: "aPVPower", variable: "pvPower", unit: "kW"),
                         RawVariable(name: "aPV2Volt", variable: "pv2Volt", unit: "V"),
                         RawVariable(name: "aPV2Current", variable: "pv2Current", unit: "A"),
                         RawVariable(name: "bPV1Current", variable: "pv1Current", unit: "A"),
                         RawVariable(name: "bPV1Power", variable: "pv1Power", unit: "kW"),
                         RawVariable(name: "bPVPower", variable: "pvPower", unit: "kW"),
                         RawVariable(name: "bPV2Volt", variable: "pv2Volt", unit: "V"),
                         RawVariable(name: "cPV2Current", variable: "pv2Current", unit: "A"),
                         RawVariable(name: "cPV1Current", variable: "pv1Current", unit: "A"),
                         RawVariable(name: "cPV1Power", variable: "pv1Power", unit: "kW"),
                         RawVariable(name: "cPVPower", variable: "pvPower", unit: "kW"),
                         RawVariable(name: "cPV2Volt", variable: "pv2Volt", unit: "V"),
                         RawVariable(name: "dPV2Current", variable: "pv2Current", unit: "A"),
                         RawVariable(name: "dPV2Power", variable: "pv2Power", unit: "kW")].map { ParameterGraphVariable($0, isSelected: [true, false].randomElement()!) }

        return ParameterGraphVariableChooserView(
            viewModel: ParameterGraphVariableChooserViewModel(variables: variables,
                                                              configManager: PreviewConfigManager(),
                                                              onApply: { _ in }))
    }
}
