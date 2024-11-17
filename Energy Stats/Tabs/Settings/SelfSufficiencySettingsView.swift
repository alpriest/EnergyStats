//
//  SelfSufficiencySettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/06/2023.
//

import Energy_Stats_Core
import SwiftUI

class SelfSufficiencySettingsViewModel: ObservableObject {
    @Published var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        didSet {
            configManager.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        }
    }

    @Published var showSelfSufficiencyStatsGraphOverlay: Bool {
        didSet {
            configManager.showSelfSufficiencyStatsGraphOverlay = showSelfSufficiencyStatsGraphOverlay
        }
    }

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        selfSufficiencyEstimateMode = configManager.selfSufficiencyEstimateMode
        showSelfSufficiencyStatsGraphOverlay = configManager.showSelfSufficiencyStatsGraphOverlay
    }
}

struct SelfSufficiencySettingsView: View {
    @State private var internalMode: Int
    @StateObject private var viewModel: SelfSufficiencySettingsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: SelfSufficiencySettingsViewModel(configManager: configManager))
        internalMode = configManager.selfSufficiencyEstimateMode.rawValue
    }

    var body: some View {
        Form {
            Section {
                Picker("Self sufficiency estimates", selection: $internalMode) {
                    Text("Off").tag(0)
                    Text("Net").tag(1)
                    Text("Absolute").tag(2)
                }.pickerStyle(.segmented)
            } footer: {
                switch internalMode {
                case SelfSufficiencyEstimateMode.absolute.rawValue:
                    Text("absolute_self_sufficiency")
                case SelfSufficiencyEstimateMode.net.rawValue:
                    Text("net_self_sufficiency")
                default:
                    Text("no_self_sufficiency")
                }
            }.onChange(of: internalMode) { newValue in
                viewModel.selfSufficiencyEstimateMode = SelfSufficiencyEstimateMode(rawValue: newValue) ?? .off
            }

            if internalMode != SelfSufficiencyEstimateMode.off.rawValue {
                Section {
                    Toggle(isOn: $viewModel.showSelfSufficiencyStatsGraphOverlay) {
                        Text("Show self sufficiency percentage on stats graph")
                    }
                }
            }
        }
        .navigationTitle(.selfSufficiencyEstimates)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SelfSufficiencySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SelfSufficiencySettingsView(configManager: ConfigManager.preview())
    }
}
