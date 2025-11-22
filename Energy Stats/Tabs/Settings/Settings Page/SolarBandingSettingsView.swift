//
//  SolarBandingSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SolarBandingSettingsViewData: Copiable {
    var solarDefinitions: SolarRangeDefinitions
    
    func create(copying previous: SolarBandingSettingsViewData) -> SolarBandingSettingsViewData {
        SolarBandingSettingsViewData(solarDefinitions: previous.solarDefinitions)
    }
    
    private static func approxEqual(_ a: Double, _ b: Double, epsilon: Double = 0.0001) -> Bool {
        return abs(a - b) < epsilon
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        approxEqual(lhs.solarDefinitions.breakPoint1, rhs.solarDefinitions.breakPoint1) &&
        approxEqual(lhs.solarDefinitions.breakPoint2, rhs.solarDefinitions.breakPoint2) &&
        approxEqual(lhs.solarDefinitions.breakPoint3, rhs.solarDefinitions.breakPoint3)
    }
}

class SolarBandingSettingsViewModel: ObservableObject, ViewDataProviding {
    typealias ViewData = SolarBandingSettingsViewData
    
    private var configManager: ConfigManaging
    let haptic = UIImpactFeedbackGenerator()
    @Published var viewData: ViewData { didSet {
        isDirty = viewData != originalValue
    }}
    @Published var isDirty = false
    var originalValue: ViewData?

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        haptic.prepare()
        let viewData = ViewData(solarDefinitions: configManager.solarDefinitions)
        originalValue = viewData
        self.viewData = viewData
    }

    func save(breakpoint1: Double, breakpoint2: Double, breakpoint3: Double) {
        configManager.solarDefinitions = SolarRangeDefinitions(
            breakPoint1: breakpoint1,
            breakPoint2: breakpoint2,
            breakPoint3: breakpoint3
        )
        resetDirtyState()
    }
    
    func didUpdate(breakpoint1: Double, breakpoint2: Double, breakpoint3: Double) {
        viewData = viewData.copy {
            $0.solarDefinitions = SolarRangeDefinitions(breakPoint1: breakpoint1, breakPoint2: breakpoint2, breakPoint3: breakpoint3)
        }
    }
}

struct SolarBandingSettingsView: View {
    @StateObject var viewModel: SolarBandingSettingsViewModel
    @State private var breakpoint1: Double
    @State private var breakpoint2: Double
    @State private var breakpoint3: Double
    @State private var modifiedAppTheme: AppSettings
    private var range = 0.1 ... 10
    private let appSettings: AppSettings

    init(configManager: ConfigManaging) {
        _viewModel = .init(wrappedValue: SolarBandingSettingsViewModel(configManager: configManager))
        self.breakpoint1 = configManager.solarDefinitions.breakPoint1
        self.breakpoint2 = configManager.solarDefinitions.breakPoint2
        self.breakpoint3 = configManager.solarDefinitions.breakPoint3
        self.appSettings = configManager.appSettingsPublisher.value
        self.modifiedAppTheme = appSettings
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
                    AdjustableView(appSettings: modifiedAppTheme, 
                                   config: MockConfig(),
                                   maximum: breakpoint3 + 0.500,
                                   thresholds: [breakpoint1, breakpoint2, breakpoint3])
                } header: {
                    Text("Example")
                } footer: {
                    Text("solar_example_description")
                }

                FooterSection {
                    Button {
                        breakpoint1 = 1
                        breakpoint2 = 2
                        breakpoint3 = 3
                        verifyThresholds()
                    } label: {
                        Text("Restore defaults")
                    }
                    .buttonStyle(.bordered)
                }
            }.onChange(of: breakpoint1) { newValue in
                if breakpoint1 >= breakpoint2 {
                    breakpoint1 = breakpoint2 - 0.1
                }

                verifyThresholds()
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

            BottomButtonsView(dirty: viewModel.isDirty) {
                viewModel.save(breakpoint1: breakpoint1,
                                 breakpoint2: breakpoint2,
                                 breakpoint3: breakpoint3)
            }
        }
        .navigationTitle(.sunDisplayVariationThresholds)
        .navigationBarTitleDisplayMode(.inline)
    }

    func verifyThresholds() {
        if breakpoint2 <= breakpoint1 {
            breakpoint2 = breakpoint1 + 0.1
        }

        if breakpoint3 <= breakpoint2 {
            breakpoint3 = breakpoint2 + 0.1
        }
        
        viewModel.didUpdate(breakpoint1: breakpoint1, breakpoint2: breakpoint2, breakpoint3: breakpoint3)
    }

    func makeAppTheme() -> AppSettings {
        appSettings
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
                configManager: ConfigManager.preview()
            )
        }
        .environment(\.locale, .init(identifier: "en"))
    }
}
