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
        VStack(spacing: 0) {
            Form {
                Section {
                    Text("Solcast_description")
                    SecureField("API Key", text: $viewModel.apiKey)
                }

                Section {
                    Toggle(isOn: $viewModel.showSolcastOnParametersPage) {
                        Text("Show solar forecast on parameters page")
                    }
                } footer: {
                    Text("Solcast provides only future data, which is fetched when the app is launched. To view today’s prediction, you must have opened the app yesterday")
                }

                ForEach(viewModel.sites, id: \.resourceId) { site in
                    Section {
                        SolcastSiteView(site: site)
                    }
                }

                FooterSection {
                    Button("Remove key", action: { viewModel.removeKey() })
                        .buttonStyle(.bordered)
                }
            }

            BottomButtonsView {
                viewModel.save()
            }
        }
        .navigationTitle(.solarPrediction)
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationView {
        SolcastSettingsView(configManager: ConfigManager.preview()) { DemoSolcast() }
    }
}
