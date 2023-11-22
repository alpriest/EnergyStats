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

    init(configManager: ConfigManaging, solarService: @escaping SolarForecastProviding) {
        _viewModel = .init(wrappedValue: SolcastSettingsViewModel(configManager: configManager, solarService: solarService))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Text("Solcast_description")
                        SecureField("API Key", text: $viewModel.apiKey)
                    }

                    ForEach(viewModel.sites, id: \.resourceId) { site in
                        Section {
                            SolcastSiteView(site: site)
                        }
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
}

#Preview {
    SolcastSettingsView(configManager: PreviewConfigManager()) { DemoSolcast() }
}
