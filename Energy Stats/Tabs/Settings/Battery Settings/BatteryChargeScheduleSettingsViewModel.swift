//
//  BatteryChargeScheduleSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Combine
import Energy_Stats_Core
import Foundation

class BatteryChargeScheduleSettingsViewModel: ObservableObject, HasLoadState {
    private let networking: Networking
    private let config: ConfigManaging
    private var cancellable: AnyCancellable?
    @Published var state: LoadState = .inactive
    @Published var timePeriod1: ChargeTimePeriod = .init(start: Date(), end: Date(), enabled: false)
    @Published var timePeriod2: ChargeTimePeriod = .init(start: Date(), end: Date(), enabled: false)
    @Published var summary = ""
    @Published var alertContent: AlertContent?

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()

        cancellable = Publishers.Zip($timePeriod1, $timePeriod2)
            .sink { [weak self] p1, p2 in
                self?.generateSummary(period1: p1, period2: p2)
            }
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active(.loading))

            do {
                let settings = try await networking.fetchBatteryTimes(deviceSN: deviceSN)
                if let first = settings[safe: 0] {
                    timePeriod1 = ChargeTimePeriod(startTime: first.startTime, endTime: first.endTime, enabled: first.enable)
                }

                if let second = settings[safe: 1] {
                    timePeriod2 = ChargeTimePeriod(startTime: second.startTime, endTime: second.endTime, enabled: second.enable)
                }

                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not load settings"))
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active(.saving))

            do {
                let times: [ChargeTime] = [
                    timePeriod1.asChargeTime(),
                    timePeriod2.asChargeTime()
                ]

                try await networking.setBatteryTimes(deviceSN: deviceSN, times: times)
                alertContent = AlertContent(title: "Success", message: "battery_charge_schedule_settings_saved")
                await setState(.inactive)
            } catch NetworkError.foxServerError(let code, _) where code == 44096 {
                alertContent = AlertContent(title: "Failed", message: "cannot_save_due_to_active_schedule")
                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not save settings"))
            }
        }
    }

    func reset() {
        timePeriod1 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
        timePeriod2 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
    }

    func generateSummary(period1: ChargeTimePeriod, period2: ChargeTimePeriod) {
        var resultParts: [String] = []

        if !period1.enabled && !period2.enabled {
            if period1.hasTimes && period2.hasTimes {
                resultParts.append(String(format: String(key: .bothBatteryFreezePeriods), period1.description, period2.description))
            } else if period1.hasTimes {
                resultParts.append(String(format: String(key: .oneBatteryFreezePeriod), period1.description, "1"))
            } else if period2.hasTimes {
                resultParts.append(String(format: String(key: .oneBatteryFreezePeriod), period2.description, "2"))
            } else {
                resultParts.append(String(key: .noBatteryCharge))
            }
        } else if period1.enabled && period2.enabled {
            resultParts.append(String(format: String(key: .bothBatteryChargePeriods), period1.description, period2.description))

            if period1.overlaps(period2) {
                resultParts.append(String(key: .batteryPeriodsOverlap))
            }

        } else if period1.enabled {
            resultParts.append(String(format: String(key: .oneBatteryChargePeriod), period1.description))

            if period2.hasTimes {
                resultParts.append(String(format: String(key: .oneBatteryFreezePeriod), period2.description, "2"))
            }

            if period1.overlaps(period2) {
                resultParts.append(String(key: .batteryPeriodsOverlap))
            }
        } else if period2.enabled {
            resultParts.append(String(format: String(key: .oneBatteryChargePeriod), period2.description))

            if period1.hasTimes {
                resultParts.append(String(format: String(key: .oneBatteryFreezePeriod), period1.description, "1"))
            }

            if period1.overlaps(period2) {
                resultParts.append(String(key: .batteryPeriodsOverlap))
            }
        }

        summary = resultParts.joined(separator: " ")
    }
}
