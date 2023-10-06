//
//  ApproximationsSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ApproximationsSettingsView: View {
    @StateObject private var viewModel: ApproximationsSettingsViewModel
    @StateObject private var financialsViewModel: FinancialsSettingsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: ApproximationsSettingsViewModel(configManager: configManager))
        _financialsViewModel = .init(wrappedValue: FinancialsSettingsViewModel(configManager: configManager))
    }

    var body: some View {
        Form {
            SelfSufficiencySettingsView(mode: $viewModel.selfSufficiencyEstimateMode)

            FinancialsSettingsView(viewModel: financialsViewModel)
        }
        .navigationTitle("Approximations")
        .inlineNavigationBarTitle()
    }
}

#Preview {
    NavigationView {
        ApproximationsSettingsView(configManager: PreviewConfigManager())
    }
}
