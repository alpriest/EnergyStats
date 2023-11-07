//
//  BatterySOCSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatterySOCSettingsView: View {
    @StateObject var viewModel: BatterySOCSettingsViewModel

    init(networking: Networking, config: ConfigManaging, onSOCchange: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: BatterySOCSettingsViewModel(networking: networking, config: config, onSOCchange: onSOCchange))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(
                    content: {
                        HStack {
                            Text("Min SoC")
                            NumberTextField("Min SoC", text: $viewModel.soc, range: 1...100)
                                .multilineTextAlignment(.trailing)
                            Text("%")
                        }
                    },
                    footer: {
                        Text("minsoc_description")
                    }
                )

                Section(
                    content: {
                        HStack {
                            Text("Min SoC on Grid")
                            NumberTextField("Min SoC on Grid", text: $viewModel.socOnGrid, range: 1...100)
                                .multilineTextAlignment(.trailing)
                            Text("%")
                        }
                    },
                    footer: {
                        VStack(alignment: .leading) {
                            Text("minsocgrid_description")
                                .padding(.bottom)
                            Text("minsoc_detail")
                                .padding(.bottom)
                            Text("minsoc_notsure_footnote")
                        }
                    }
                )

                Section(content: {}, footer: {
                    VStack {
                        OptionalView(viewModel.errorMessage) {
                            Text($0)
                                .foregroundColor(Color.red)
                        }
                    }
                })
            }

            BottomButtonsView { viewModel.save() }
        }
        .navigationTitle("Configure Battery Charge Levels")
        .navigationBarTitleDisplayMode(.inline)
        .loadable($viewModel.state, retry: { viewModel.load() })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    BatterySOCSettingsView(networking: DemoNetworking(),
                           config: ConfigManager(networking: DemoNetworking(), config: MockConfig()),
                           onSOCchange: {})
}
