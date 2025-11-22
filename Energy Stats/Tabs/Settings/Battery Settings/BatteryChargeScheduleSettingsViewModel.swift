//
//  BatteryChargeScheduleSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Combine
import Energy_Stats_Core
import Foundation

struct BatteryChargeScheduleSettingsViewData: Copiable, Equatable {
    var timePeriod1: ChargeTimePeriod
    var timePeriod2: ChargeTimePeriod
    var summary: String

    func create(copying previous: BatteryChargeScheduleSettingsViewData) -> BatteryChargeScheduleSettingsViewData {
        BatteryChargeScheduleSettingsViewData(
            timePeriod1: previous.timePeriod1,
            timePeriod2: previous.timePeriod2,
            summary: previous.summary
        )
    }
}

class BatteryChargeScheduleSettingsViewModel: ObservableObject, HasLoadState, ViewDataProviding {
    typealias ViewData = BatteryChargeScheduleSettingsViewData
    
    private let networking: Networking
    private let config: ConfigManaging
    private var cancellable: AnyCancellable?
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var isDirty = false
    @Published var viewData = ViewData(
        timePeriod1: .init(start: Date(), end: Date(), enabled: false),
        timePeriod2: .init(start: Date(), end: Date(), enabled: false),
        summary: ""
    ) { didSet {
        isDirty = viewData != originalValue
    }}
    var originalValue: ViewData?

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active(.loading))

            do {
                let settings = try await networking.fetchBatteryTimes(deviceSN: deviceSN)
                let timePeriod1: ChargeTimePeriod
                let timePeriod2: ChargeTimePeriod

                if let first = settings[safe: 0] {
                    timePeriod1 = ChargeTimePeriod(startTime: first.startTime, endTime: first.endTime, enabled: first.enable)
                } else {
                    timePeriod1 = .now()
                }

                if let second = settings[safe: 1] {
                    timePeriod2 = ChargeTimePeriod(startTime: second.startTime, endTime: second.endTime, enabled: second.enable)
                } else {
                    timePeriod2 = .now()
                }
                
                let viewData = ViewData(
                    timePeriod1: timePeriod1,
                    timePeriod2: timePeriod2,
                    summary: generateSummary(period1: timePeriod1, period2: timePeriod2)
                )
                self.originalValue = viewData
                self.viewData = viewData

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
                    viewData.timePeriod1.asChargeTime(),
                    viewData.timePeriod2.asChargeTime()
                ]

                try await networking.setBatteryTimes(deviceSN: deviceSN, times: times)
                resetDirtyState()
                alertContent = AlertContent(title: "Success", message: "battery_charge_schedule_settings_saved")
                await setState(.inactive)
            } catch let NetworkError.foxServerError(code, _) where code == 44096 {
                alertContent = AlertContent(title: "Failed", message: "cannot_save_due_to_active_schedule")
                await setState(.inactive)
            } catch {
                await setState(.error(error, "Could not save settings"))
            }
        }
    }

    func reset() {
        viewData = viewData.copy {
            $0.timePeriod1 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
            $0.timePeriod2 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
        }
    }

    func updateSummary(period1: ChargeTimePeriod, period2: ChargeTimePeriod) {
        viewData = viewData.copy {
            $0.summary = generateSummary(period1: period1, period2: period2)
        }
    }

    func generateSummary(period1: ChargeTimePeriod, period2: ChargeTimePeriod) -> String {
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
        
        return resultParts.joined(separator: " ")
    }
}

extension ChargeTimePeriod {
    static func now() -> ChargeTimePeriod {
        .init(start: Date(), end: Date(), enabled: false)
    }
}
