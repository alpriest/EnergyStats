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
    @Published var resourceId: String = ""
    @Published var apiKey: String = ""

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        resourceId = configManager.solcastResourceId ?? ""
        apiKey = configManager.solcastApiKey ?? ""
    }

    func save() {
        configManager.solcastResourceId = resourceId
        configManager.solcastApiKey = apiKey
    }
}

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
                }
            }

            BottomButtonsView {
                viewModel.save()
            }
        }
        .navigationTitle("Solcast Solar Prediction")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SolcastSettingsView(configManager: PreviewConfigManager())
}
