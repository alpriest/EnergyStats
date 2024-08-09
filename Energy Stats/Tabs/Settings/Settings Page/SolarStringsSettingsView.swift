//
//  SolarStringsSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/02/2024.
//

import Energy_Stats_Core
import SwiftUI

struct SolarStringsSettingsView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @State private var showStringSelection: Bool
    @State private var pv1: Bool
    @State private var pv2: Bool
    @State private var pv3: Bool
    @State private var pv4: Bool
    @State private var pv5: Bool
    @State private var pv6: Bool
    @State private var pv1Name: String
    @State private var pv2Name: String
    @State private var pv3Name: String
    @State private var pv4Name: String
    @State private var pv5Name: String
    @State private var pv6Name: String
    @State private var alert: AlertContent?

    init(viewModel: SettingsTabViewModel) {
        self.viewModel = viewModel
        self._showStringSelection = State(wrappedValue: viewModel.powerFlowStrings.enabled)
        self._pv1 = State(wrappedValue: viewModel.powerFlowStrings.pv1Enabled)
        self._pv2 = State(wrappedValue: viewModel.powerFlowStrings.pv2Enabled)
        self._pv3 = State(wrappedValue: viewModel.powerFlowStrings.pv3Enabled)
        self._pv4 = State(wrappedValue: viewModel.powerFlowStrings.pv4Enabled)
        self._pv5 = State(wrappedValue: viewModel.powerFlowStrings.pv5Enabled)
        self._pv6 = State(wrappedValue: viewModel.powerFlowStrings.pv6Enabled)
        self._pv1Name = State(wrappedValue: viewModel.powerFlowStrings.pv1Name)
        self._pv2Name = State(wrappedValue: viewModel.powerFlowStrings.pv2Name)
        self._pv3Name = State(wrappedValue: viewModel.powerFlowStrings.pv3Name)
        self._pv4Name = State(wrappedValue: viewModel.powerFlowStrings.pv4Name)
        self._pv5Name = State(wrappedValue: viewModel.powerFlowStrings.pv5Name)
        self._pv6Name = State(wrappedValue: viewModel.powerFlowStrings.pv6Name)
    }

    var body: some View {
        VStack {
            Toggle(isOn: $showStringSelection) {
                HStack {
                    Text("Show PV power by strings")
                    InfoButtonView(message: "settings.pvpower.strings.description")
                }
            }
            .onChange(of: showStringSelection) { newValue in
                viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(enabled: newValue)
            }

            if showStringSelection {
                VStack {
                    editableStringToggle(for: "PV1", $pv1, $pv1Name)
                    editableStringToggle(for: "PV2", $pv2, $pv2Name)
                    editableStringToggle(for: "PV3", $pv3, $pv3Name)
                    editableStringToggle(for: "PV4", $pv4, $pv4Name)
                    editableStringToggle(for: "PV5", $pv5, $pv5Name)
                    editableStringToggle(for: "PV6", $pv6, $pv6Name)
                }.onChange(of: pv1) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv1Enabled: $0)
                }.onChange(of: pv2) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv2Enabled: $0)
                }.onChange(of: pv3) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv3Enabled: $0)
                }.onChange(of: pv4) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv4Enabled: $0)
                }.onChange(of: pv5) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv5Enabled: $0)
                }.onChange(of: pv6) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv6Enabled: $0)
                }.onChange(of: pv1Name) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv1Name: $0)
                }.onChange(of: pv2Name) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv2Name: $0)
                }.onChange(of: pv3Name) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv3Name: $0)
                }.onChange(of: pv4Name) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv4Name: $0)
                }.onChange(of: pv5Name) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv5Name: $0)
                }.onChange(of: pv6Name) {
                    viewModel.powerFlowStrings = viewModel.powerFlowStrings.copy(pv6Name: $0)
                }
            }
        }
    }

    private func editableStringToggle(for title: String, _ enabled: Binding<Bool>, _ name: Binding<String>) -> some View {
        Toggle(isOn: enabled) {
            TextField(text: name) {
                Text(title)
            }.textFieldStyle(.roundedBorder)
        }
    }
}

#if DEBUG
#Preview {
    SolarStringsSettingsView(viewModel: SettingsTabViewModel(
        userManager: .preview(),
        config: ConfigManager.preview(),
        networking: NetworkService.preview())
    )
}
#endif
