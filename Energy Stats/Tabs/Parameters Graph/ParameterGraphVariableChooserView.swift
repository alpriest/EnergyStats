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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Button("Default") { viewModel.chooseDefaultVariables() }
                    Button("Compare strings") { viewModel.chooseCompareStringsVariables() }
                    Button("Temperatures") { viewModel.chooseTemperatureVariables() }
                    Button("None") { viewModel.select(just: []) }
                } header: {
                    Text("Predefined selections")
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
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } header: {
                    Text("All")
                }
            }

            VStack(spacing: 0) {
                Color("BottomBarDivider")
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("cancel")

                    Button(action: {
                        viewModel.apply()
                        dismiss()
                    }) {
                        Text("Apply")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }

                Text("Note that not all parameters contain values")
            }
        }
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

        return ParameterGraphVariableChooserView(viewModel: ParameterGraphVariableChooserViewModel(variables: variables, onApply: { _ in }))
    }
}
