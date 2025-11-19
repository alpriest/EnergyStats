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
    @State private var showAllParameters = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section {
                        List {
                            Button("Default") { viewModel.chooseDefaultVariables() }
                            Button("None") { viewModel.select(just: []) }

                            ForEach(viewModel.groups, id: \.title) { group in
                                Button {
                                    viewModel.select(group)
                                } label: {
                                    HStack {
                                        Text(group.title)
                                        Spacer()

                                        if viewModel.selected == group.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } header: {
                        VStack(alignment: .leading) {
                            Text("Select a group below to focus on commonly used parameters, or create your own using the Manage groups button.")

                            Text("Groups")
                                .padding(.top)
                        }
                    }

                    Section {
                        ParameterVariableListView(
                            variables: viewModel.variables.filter { showAllParameters || $0.isSelected },
                            onTap: viewModel.toggle
                        )
                    } header: {
                        HStack {
                            Text("Parameters")
                            Spacer()
                            Button {
                                showAllParameters.toggle()
                            } label: {
                                Text(showAllParameters ? "Show only selected" : "Show all")
                            }
                        }
                    } footer: {
                        FindOutMoreView(urlString: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/Fox-ESS-Cloud#search-parameters")
                    }
                }

                BottomButtonsView(dirty: true,
                                  onApply: {
                                      viewModel.apply()
                                      dismiss()
                                  }, onCancel: {
                                      dismiss()
                                  }, footer: {
                                      Text("Note that not all parameters contain values")
                                  })
            }
            .navigationTitle(.parameters)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: { ParameterVariableGroupEditorView(viewModel: ParameterVariableGroupEditorViewModel(configManager: viewModel.configManager)) },
                               label: { Text("Manage groups") })
            } }
        }
    }

    private var isEditing: Bool {
        editMode.isEditing == true
    }
}

#Preview {
    let variables = Variable.previewList().map { ParameterGraphVariable($0, isSelected: [true, false].randomElement()!) }

    return ParameterGraphVariableChooserView(
        viewModel: ParameterGraphVariableChooserViewModel(variables: variables,
                                                          configManager: ConfigManager.preview(),
                                                          onApply: { _ in }))
}

extension Variable {
    static func previewList() -> [Variable] {
        [Variable(name: "PV1Volt", variable: "pv1Volt", unit: "V"),
         Variable(name: "PV1Current", variable: "pv1Current", unit: "A"),
         Variable(name: "PV1Power", variable: "pv1Power", unit: "kW"),
         Variable(name: "PVPower", variable: "pvPower", unit: "kW"),
         Variable(name: "PV2Volt", variable: "pv2Volt", unit: "V"),
         Variable(name: "PV2Current", variable: "pv2Current", unit: "A"),
         Variable(name: "generationPower", variable: "generationPower", unit: "A"),
         Variable(name: "batChargePower", variable: "batChargePower", unit: "kW"),
         Variable(name: "batDischargePower", variable: "batDischargePower", unit: "kW"),
         Variable(name: "feedinPower", variable: "feedinPower", unit: "V"),
         Variable(name: "gridConsumptionPower", variable: "gridConsumptionPower", unit: "A"),
         Variable(name: "bPV1Current", variable: "pv1Current", unit: "A"),
         Variable(name: "bPV1Power", variable: "pv1Power", unit: "kW"),
         Variable(name: "bPVPower", variable: "pvPower", unit: "kW"),
         Variable(name: "bPV2Volt", variable: "pv2Volt", unit: "V"),
         Variable(name: "batTemperature", variable: "batTemperature", unit: "A"),
         Variable(name: "batVolt", variable: "batVolt", unit: "A"),
         Variable(name: "batCurrent", variable: "batCurrent", unit: "kW"),
         Variable(name: "SoC", variable: "SoC", unit: "kW"),
         Variable(name: "cPV2Volt", variable: "pv2Volt", unit: "V"),
         Variable(name: "dPV2Current", variable: "pv2Current", unit: "A"),
         Variable(name: "dPV2Power", variable: "pv2Power", unit: "kW")]
    }
}
