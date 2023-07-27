//
//  BatteryForceChargeSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI

class BatteryForceChargeSettingsViewModel: ObservableObject {
    private let networking: Networking
    private let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var timePeriod1: ChargeTimePeriod = .init(enabled: false)
    @Published var timePeriod2: ChargeTimePeriod = .init(enabled: false)

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active("Loading...")

            do {
                let settings = try await networking.fetchBatteryTimes(deviceSN: deviceSN)
                if let first = settings.times[safe: 0] {
                    timePeriod1 = ChargeTimePeriod(startTime: first.startTime, endTime: first.endTime, enabled: first.enableGrid)
                }

                if let second = settings.times[safe: 1] {
                    timePeriod2 = ChargeTimePeriod(startTime: second.startTime, endTime: second.endTime, enabled: second.enableGrid)
                }

                state = .inactive
            } catch {
                state = .error(error, "Could not load settings")
            }
        }
    }

    func save() {
        Task { @MainActor in
        }
    }

    var valid: Bool {
        timePeriod1.valid && timePeriod2.valid
    }
}

struct BatteryForceChargeSettingsView: View {
    @StateObject var viewModel: BatteryForceChargeSettingsViewModel

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: BatteryForceChargeSettingsViewModel(networking: networking, config: config))
    }

    var body: some View {
        Group {
            BatteryTimePeriodView(timePeriod: $viewModel.timePeriod1, title: "Force charge period 1")
            BatteryTimePeriodView(timePeriod: $viewModel.timePeriod2, title: "Force charge period 2")

            Section(content: {}, footer: {
                VStack {
                    Button(action: {}, label: {
                        Text("Save")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.valid)
                }
            })
        }
        .loadable($viewModel.state, retry: { viewModel.load() })
    }
}

struct BatteryForceChargeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            BatteryForceChargeSettingsView(networking: DemoNetworking(),
                                           config: ConfigManager(networking: DemoNetworking(), config: MockConfig()))
        }
    }
}
