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
        Form {
            Section(
                content: {
                    HStack {
                        Text("Min SoC")
                        NumberTextField("Min SoC", text: $viewModel.soc)
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
                        NumberTextField("Min SoC on Grid", text: $viewModel.socOnGrid)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                },
                footer: {
                    VStack(alignment: .leading) {
                        Text("The minimum charge the battery should maintain when grid power is present.")
                            .padding(.bottom)
                        Text("For the most part this is the setting that determines when the batteries will stop being used. Setting this higher than Min SoC will reserve battery power for a grid outage. For example, if you set Min SoC to 10% and Min SoC on Grid to 20%, the inverter will stop supplying power from the batteries at 20% and the house load will be supplied from the grid. If there is a grid outage, the batteries could be used (via an EPS switch) to supply emergency power until the battery charge drops to 10%.")
                            .padding(.bottom)
                        Text("If you're not sure then set both values the same.")
                    }
                }
            )

            Section(content: {}, footer: {
                VStack {
                    OptionalView(viewModel.errorMessage) {
                        Text($0)
                            .foregroundColor(Color.red)
                    }

                    Button(action: {
                        viewModel.save()
                    }, label: {
                        Text("Save")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                }
            })
        }
        .loadable($viewModel.state, retry: { viewModel.load() })
    }
}

struct BatterySOCSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            BatterySOCSettingsView(networking: DemoNetworking(),
                                   config: ConfigManager(networking: DemoNetworking(), config: MockConfig()),
                                   onSOCchange: {})
        }
    }
}
