//
//  BatterySOCSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI

class BatterySOCSettingsViewModel: ObservableObject {
    private let networking: Networking
    private let config: ConfigManaging
    @Published var soc: String = ""
    @Published var socOnGrid: String = ""
    @Published var errorMessage: String?
    @Published var state: LoadState = .inactive
    private let onSOCchange: () -> Void

    init(networking: Networking, config: ConfigManaging, onSOCchange: @escaping () -> Void) {
        self.networking = networking
        self.config = config
        self.onSOCchange = onSOCchange

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active("Loading...")

            do {
                let settings = try await networking.fetchBatterySettings(deviceSN: deviceSN)
                self.soc = String(describing: settings.minSoc)
                self.socOnGrid = String(describing: settings.minGridSoc)

                state = .inactive
            } catch {
                state = .error(error, "Could not load settings")
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard let soc = Int(soc), let socOnGrid = Int(socOnGrid), let deviceSN = config.currentDevice.value?.deviceSN else {
                errorMessage = "Cannot save, please check values"
                return
            }
            state = .active("Saving...")

            do {
                try await networking.setSoc(
                    minGridSOC: soc,
                    minSOC: socOnGrid,
                    deviceSN: deviceSN
                )

                onSOCchange()

                state = .inactive
            } catch {
                state = .error(error, "Could not save settings")
            }
        }
    }
}

struct BatterySOCSettingsView: View {
    @StateObject var viewModel: BatterySOCSettingsViewModel

    init(networking: Networking, config: ConfigManaging, onSOCchange: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: BatterySOCSettingsViewModel(networking: networking, config: config, onSOCchange: onSOCchange))
    }

    var body: some View {
        Group {
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
                    Text("The minimum charge the battery should maintain.")
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
