//
//  BatteryForceChargeSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Foundation
import Energy_Stats_Core

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
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active("Saving...")

            do {
                let times: [ChargeTime] = [
                    timePeriod1.asChargeTime(),
                    timePeriod2.asChargeTime()
                ]

                try await networking.setBatteryTimes(deviceSN: deviceSN, times: times)
                state = .inactive
            } catch {
                state = .error(error, "Could not save settings")
            }
        }
    }

    var valid: Bool {
        timePeriod1.valid && timePeriod2.valid
    }
}
