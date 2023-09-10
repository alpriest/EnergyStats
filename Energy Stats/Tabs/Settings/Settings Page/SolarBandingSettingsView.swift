//
//  SolarBandingSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SolarBandingSettingsView: View {
    @State private var change1: Double
    @State private var change2: Double
    @State private var change3: Double
    @State private var modifiedAppTheme: AppTheme
    private var range = 0.1 ... 10
    private let appTheme: AppTheme

    init(configManager: ConfigManaging) {
        self.change1 = configManager.solarDefinitions.breakPoint1
        self.change2 = configManager.solarDefinitions.breakPoint2
        self.change3 = configManager.solarDefinitions.breakPoint3
        self.appTheme = configManager.appTheme.value
        self.modifiedAppTheme = appTheme
        self.modifiedAppTheme = makeAppTheme()
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    AdjustableView(appTheme: modifiedAppTheme, config: MockConfig(), maximum: change3 + 0.500)
                } header: {
                    Text("Example")
                } footer: {
                    Text("solar_example_description")
                }

                Section {
                    HStack {
                        Slider(value: $change1, in: range, step: 0.1)
                        Text(change1.kWh(3))
                    }
                } header: {
                    Text(String(key: .breakpoint, arguments: ["1"]))
                }

                Section {
                    HStack {
                        Slider(value: $change2, in: range, step: 0.1)
                        Text(change2.kWh(3))
                    }
                } header: {
                    Text(String(key: .breakpoint, arguments: ["2"]))
                }

                Section {
                    HStack {
                        Slider(value: $change3, in: range, step: 0.1)
                        Text(change3.kWh(3))
                    }
                } header: {
                    Text(String(key: .breakpoint, arguments: ["3"]))
                }

                Button {
                    change1 = 1
                    change2 = 2
                    change3 = 3
                } label: {
                    Text("Restore defaults")
                }
            }.onChange(of: change1) { newValue in
                if newValue > change2 {
                    change2 = newValue
                }
                if change2 > change3 {
                    change3 = change2
                }

                modifiedAppTheme = makeAppTheme()
            }
            .onChange(of: change2) { newValue in
                if newValue < change1 {
                    change1 = newValue
                }
                if newValue > change3 {
                    change3 = newValue
                }

                modifiedAppTheme = makeAppTheme()
            }
            .onChange(of: change3) { newValue in
                if newValue < change2 {
                    change2 = newValue
                }
                if change2 < change1 {
                    change2 = change1
                }

                modifiedAppTheme = makeAppTheme()
            }

            BottomButtonsView {
                // TODO:
            }
        }
    }

    func makeAppTheme() -> AppTheme {
        appTheme
            .copy(solarDefinitions: SolarRangeDefinitions(
                breakPoint1: change1,
                breakPoint2: change2,
                breakPoint3: change3
            ))
    }
}

struct SolarBandingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SolarBandingSettingsView(
            configManager: PreviewConfigManager()
        )
        .environment(\.locale, .init(identifier: "es"))
    }
}
