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

                    TextField("Resource ID", text: $viewModel.site1ResourceId)
                    TextField("Optional Name", text: $viewModel.site1Name)
                    SecureField("API Key", text: $viewModel.site1ApiKey)
                } footer: {
                    Text("solcast_how_fo_find_keys")
                }

                Section {
                    TextField("Resource ID", text: $viewModel.site2ResourceId)
                    TextField("Optional Name", text: $viewModel.site2Name)
                    SecureField("API Key", text: $viewModel.site2ApiKey)
                } footer: {
                    Text("Monitor a second Solcast resource by entering details above.")
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
