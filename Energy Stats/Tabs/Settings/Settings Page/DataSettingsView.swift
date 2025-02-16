//
//  DataSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/03/2024.
//

import Energy_Stats_Core
import SwiftUI

struct Setting<C: View, F: View>: View {
    let content: C
    let footer: F?

    init(@ViewBuilder content: () -> C, footer: (() -> F)? = nil) {
        self.content = content()
        self.footer = footer?()
    }

    var body: some View {
        VStack {
            content

            if let footer {
                SettingFooter(footer: footer)
            }
        }
    }
}

struct SettingFooter<Content: View>: View {
    let footer: Content

    var body: some View {
        VStack(alignment: .leading) {
            footer
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .font(.caption)
    }
}

struct DataSettingsView: View {
    @ObservedObject var viewModel: SettingsTabViewModel

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Units").padding(.trailing)
                    Spacer()
                    Picker("Units", selection: $viewModel.displayUnit) {
                        Text("Watts").tag(DisplayUnit.watt)
                        Text("Kilowatts").tag(DisplayUnit.kilowatt)
                        Text("Adaptive").tag(DisplayUnit.adaptive)
                    }.pickerStyle(.segmented)
                }
            } footer: {
                Group {
                    switch viewModel.displayUnit {
                    case .kilowatt:
                        Text(String(key: .displayUnitKilowattsDescription, arguments: Double(3.456).kW(viewModel.decimalPlaces), Double(0.123).kW(3)))
                    case .watt:
                        Text(String(key: .displayUnitWattsDescription, arguments: Double(3.456).w(), Double(0.123).w()))
                    case .adaptive:
                        Text(String(key: .displayUnitAdaptiveDescription, arguments: Double(3.456).kW(viewModel.decimalPlaces), Double(0.123).w()))
                    }
                }
            }

            Section {
                HStack {
                    Text("Ceiling").padding(.trailing)
                    Spacer()
                    Picker("Ceiling", selection: $viewModel.dataCeiling) {
                        Text("None").tag(DataCeiling.none)
                        Text("Mild").tag(DataCeiling.mild)
                        Text("Enhanced").tag(DataCeiling.enhanced)
                    }.pickerStyle(.segmented)
                }
            } footer: {
                VStack(alignment: .leading) {
                    switch viewModel.dataCeiling {
                    case .none:
                        Text(String(key: .dataCeilingNone))
                    case .mild:
                        Text(String(key: .dataCeilingMild, arguments: [Double(201539769), Double(3461.8)]))
                    case .enhanced:
                        Text(String(key: .dataCeilingEnhanced, arguments: [Double(458997), Double(245)]))
                    }
                }
            }

            Section {
                HStack {
                    Text("Refresh").padding(.trailing)
                    Picker("Refresh frequency", selection: $viewModel.refreshFrequency) {
                        Text("1 min").tag(RefreshFrequency.ONE_MINUTE)
                        Text("5 mins").tag(RefreshFrequency.FIVE_MINUTES)
                        Text("Auto").tag(RefreshFrequency.AUTO)
                    }
                    .pickerStyle(.segmented)
                }
            } footer: {
                Text("FoxESS Cloud data is updated every 5 minutes. 'Auto' attempts to synchronise data fetches just after the data is uploaded from your inverter to minimise server load.")
            }
        }
        .navigationTitle(.data)
    }
}

#if DEBUG
#Preview {
    NavigationView {
        DataSettingsView(
            viewModel: SettingsTabViewModel(
                userManager: .preview(),
                config: ConfigManager.preview(),
                networking: NetworkService.preview()
            )
        )
    }
}
#endif
