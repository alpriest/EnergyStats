//
//  SolcastSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SolcastSettingsView: View {
    @StateObject var viewModel: SolcastSettingsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: SolcastSettingsViewModel(configManager: configManager))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Text("Solcast_description")
                    TextField("Resource ID", text: $viewModel.resourceId)
                    SecureField("API Key", text: $viewModel.apiKey)
                } footer: {
                    Text("solcast_how_fo_find_keys")
                }
            }

            BottomButtonsView {
                viewModel.save()
            }
        }
        .navigationTitle("Solcast Solar Prediction")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    SolcastSettingsView(configManager: PreviewConfigManager())
}
