//
//  SolcastSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/11/2023.
//

import Energy_Stats_Core
import SwiftUI

class SolcastSettingsViewModel: ObservableObject {
    private var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
    }

    func save(resourceId: String, apiKey: String) {
        configManager.solcastResourceId = resourceId
        configManager.solcastApiKey = apiKey
    }
}

struct SolcastSettingsView: View {
    @StateObject var viewModel: SolcastSettingsViewModel

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: SolcastSettingsViewModel(configManager: configManager))
    }

    @State private var resourceId: String = ""
    @State private var apiKey: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Text("""
                    Solcast provide solar predictions based on your location. To sign up for free, visit https://solcast.com/free-rooftop-solar-forecasting and register for Hobbyist Access.

                    Once you've signed up and have created your site, paste the resource ID and your API key below.
                    """)

                    TextField("Resource ID", text: $resourceId)
                    TextField("API Key", text: $apiKey)
                }
            }

            BottomButtonsView {
                viewModel.save(resourceId: resourceId, apiKey: apiKey)
            }
        }
        .navigationTitle("Solcast Solar Prediction")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SolcastSettingsView(configManager: PreviewConfigManager())
}
