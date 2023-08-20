//
//  ApproximationsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/08/2023.
//

import Energy_Stats_Core
import SwiftUI

class ApproximationsViewModel: ObservableObject {
    @Published var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        didSet {
            configManager.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        }
    }

    @Published var showEarnings: Bool {
        didSet {
            configManager.showEarnings = showEarnings
        }
    }

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        selfSufficiencyEstimateMode = configManager.selfSufficiencyEstimateMode
        showEarnings = configManager.showEarnings
    }
}

struct ApproximationsView: View     {
    @StateObject private var viewModel: ApproximationsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: ApproximationsViewModel(configManager: configManager))
    }

    var body: some View {
        Form {
            SelfSufficiencySettingsView(mode: $viewModel.selfSufficiencyEstimateMode)

            Section {
                Toggle(isOn: $viewModel.showEarnings) {
                    Text("Show estimated earnings")
                }
            } footer: {
                Text("Shows earnings today, this month, this year, and all-time based on a crude calculation of feed-in ｘ price as configured on FoxESS cloud.")
            }
        }
        .navigationTitle("Approximations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ApproximationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ApproximationsView(configManager: PreviewConfigManager())
        }
    }
}
