//
//  SolarBandingSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2023.
//

import Energy_Stats_Core
import SwiftUI

class SolarBandingSettingsViewModel: ObservableObject {
    private var configManager: ConfigManaging
    let haptic = UIImpactFeedbackGenerator()

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        haptic.prepare()
    }

    func update(breakpoint1: Double, breakpoint2: Double, breakpoint3: Double) {
        configManager.solarDefinitions = SolarRangeDefinitions(
            breakPoint1: breakpoint1,
            breakPoint2: breakpoint2,
            breakPoint3: breakpoint3
        )
    }
}

struct SolarBandingSettingsView: View {
    @StateObject var viewModel: SolarBandingSettingsViewModel
    @State private var breakpoint1: Double
    @State private var breakpoint2: Double
    @State private var breakpoint3: Double
    @State private var modifiedAppTheme: AppTheme
    private var range = 0.1 ... 10
    private let appTheme: AppTheme

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: SolarBandingSettingsViewModel(configManager: configManager))
        self.breakpoint1 = configManager.solarDefinitions.breakPoint1
        self.breakpoint2 = configManager.solarDefinitions.breakPoint2
        self.breakpoint3 = configManager.solarDefinitions.breakPoint3
        self.appTheme = configManager.appTheme.value
        self.modifiedAppTheme = appTheme
        self.modifiedAppTheme = makeAppTheme()
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    HStack {
                        Slider(value: $breakpoint1, in: range, step: 0.1)
                        Text(breakpoint1.kW(3))
                    }
                } header: {
                    Text("low_threshold")
                } footer: {
                    Text("low_threshold_description")
                }

                Section {
                    HStack {
                        Slider(value: $breakpoint2, in: range, step: 0.1)
                        Text(breakpoint2.kW(3))
                    }
                } header: {
                    Text("medium_threshold")
                } footer: {
                    Text("medium_threshold_description")
                }

                Section {
                    HStack {
                        Slider(value: $breakpoint3, in: range, step: 0.1)
                        Text(breakpoint3.kW(3))
                    }
                } header: {
                    Text("high_threshold")
                } footer: {
                    Text("high_threshold_description")
                }

                Section {
                    AdjustableView(appTheme: modifiedAppTheme, 
                                   config: MockConfig(),
                                   maximum: breakpoint3 + 0.500,
                                   thresholds: [breakpoint1, breakpoint2, breakpoint3])
                } header: {
                    Text("Example")
                } footer: {
                    Text("solar_example_description")
                }

                Button {
                    breakpoint1 = 1
                    breakpoint2 = 2
                    breakpoint3 = 3
                } label: {
                    Text("Restore defaults")
                }
            }.onChange(of: breakpoint1) { newValue in
                if breakpoint1 >= breakpoint2 {
                    breakpoint1 = breakpoint2 - 0.1
                }

                modifiedAppTheme = makeAppTheme()
            }
            .onChange(of: breakpoint2) { newValue in
                if breakpoint2 >= breakpoint3 {
                    breakpoint2 = breakpoint3 - 0.1
                }

                verifyThresholds()
                modifiedAppTheme = makeAppTheme()
            }
            .onChange(of: breakpoint3) { newValue in
                verifyThresholds()
                modifiedAppTheme = makeAppTheme()
            }

            BottomButtonsView {
                viewModel.update(breakpoint1: breakpoint1,
                                 breakpoint2: breakpoint2,
                                 breakpoint3: breakpoint3)
            }
        }
        .navigationTitle("Sun display variation thresholds")
        .navigationBarTitleDisplayMode(.inline)
    }

    func verifyThresholds() {
        if breakpoint2 <= breakpoint1 {
            breakpoint2 = breakpoint1 + 0.1
        }

        if breakpoint3 <= breakpoint2 {
            breakpoint3 = breakpoint2 + 0.1
        }
    }

    func makeAppTheme() -> AppTheme {
        appTheme
            .copy(solarDefinitions: SolarRangeDefinitions(
                breakPoint1: breakpoint1,
                breakPoint2: breakpoint2,
                breakPoint3: breakpoint3
            ))
    }
}

struct SolarBandingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SolarBandingSettingsView(
                configManager: PreviewConfigManager()
            )
        }
        .environment(\.locale, .init(identifier: "en"))
    }
}
