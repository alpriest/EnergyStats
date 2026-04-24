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
    @FocusState private var isFocused: Bool

    init(configManager: ConfigManaging, solarService: @escaping SolarForecastProviding) {
        _viewModel = .init(wrappedValue: SolcastSettingsViewModel(configManager: configManager, solarService: solarService))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Text("Solcast_description")
                    SecureField("API Key", text: $viewModel.viewData.apiKey)
                        .focused($isFocused)
                }

                Section {
                    Toggle(isOn: $viewModel.fetchSolcastOnAppLaunch) {
                        Text("Fetch solar forecast on app launch")
                    }
                } footer: {
                    if viewModel.fetchSolcastOnAppLaunch {
                        Text("Your Solcast predictions are fetched when Energy Stats loads (at most once every 8 hours). Add the 'Solcast solar prediction' parameter on the parameters graph variable selector. Since Solcast only provides future data, you must have opened the app yesterday to view today’s prediction.")
                    } else {
                        Text("Your Solcast predictions are fetched when you visit the Summary tab (at most once every 8 hours). Note that Solcast only provides future data.")
                    }
                }
                
                Section {
                    Toggle(isOn: $viewModel.showTodayPercentageSolarForecastAchieved) {
                        Text("Show percentage of solar forecast achieved")
                    }
                }

                ForEach(viewModel.viewData.sites, id: \.resourceId) { site in
                    Section {
                        SolcastSiteView(site: site)
                    }
                }

                FooterSection {
                    Button("Remove key", action: { viewModel.removeKey() })
                        .buttonStyle(.bordered)
                }
            }

            BottomButtonsView(dirty: viewModel.isDirty) {
                viewModel.save()
                isFocused = false
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
