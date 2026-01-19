//
//  BatteryChargeScheduleSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Combine
import Energy_Stats_Core
import Foundation

struct BatteryHeatingScheduleSettingsViewData: Copiable {
    var currentState: String?
    var timePeriod1: ChargeTimePeriod
    var timePeriod2: ChargeTimePeriod
    var timePeriod3: ChargeTimePeriod
    var minStartTemperature: Double
    var maxStartTemperature: Double
    var minEndTemperature: Double
    var maxEndTemperature: Double

    func create(copying previous: BatteryHeatingScheduleSettingsViewData) -> BatteryHeatingScheduleSettingsViewData {
        BatteryHeatingScheduleSettingsViewData(
            timePeriod1: previous.timePeriod1,
            timePeriod2: previous.timePeriod2,
            timePeriod3: previous.timePeriod3,
            minStartTemperature: previous.minStartTemperature,
            maxStartTemperature: previous.maxStartTemperature,
            minEndTemperature: previous.minEndTemperature,
            maxEndTemperature: previous.maxEndTemperature
        )
    }
}

class BatteryHeatingScheduleSettingsViewModel: ObservableObject, HasLoadState, ViewDataProviding {
    typealias ViewData = BatteryHeatingScheduleSettingsViewData
    
    private let networking: Networking
    private let config: ConfigManaging
    private var cancellable: AnyCancellable?
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var isDirty = false
    @Published var viewData = ViewData(
        currentState: "The battery is in a stopped warm up state", //TODO: nil
        timePeriod1: .init(start: Date(), end: Date(), enabled: false),
        timePeriod2: .init(start: Date(), end: Date(), enabled: false),
        timePeriod3: .init(start: Date(), end: Date(), enabled: false),
        minStartTemperature: -30.0,
        maxStartTemperature: 0.0,
        minEndTemperature: 10.0,
        maxEndTemperature: 20.0
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
                let settings = try await networking.fetchBatteryHeatingSchedule(deviceSN: deviceSN)

                let timePeriod1 = ChargeTimePeriod(startTime: settings.period1Start, endTime: settings.period1End, enabled: settings.period1Enabled)
                let timePeriod2 = ChargeTimePeriod(startTime: settings.period2Start, endTime: settings.period2End, enabled: settings.period2Enabled)
                let timePeriod3 = ChargeTimePeriod(startTime: settings.period3Start, endTime: settings.period3End, enabled: settings.period3Enabled)
                
                let viewData = ViewData(
                    timePeriod1: timePeriod1,
                    timePeriod2: timePeriod2,
                    timePeriod3: timePeriod3,
                    minStartTemperature: settings.minStartTemperature,
                    maxStartTemperature: settings.maxStartTemperature,
                    minEndTemperature: settings.minEndTemperature,
                    maxEndTemperature: settings.maxEndTemperature
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
//        Task { @MainActor in
//            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
//            await setState(.active(.saving))
//
//            do {
//                let times: [ChargeTime] = [
//                    viewData.timePeriod1.asChargeTime(),
//                    viewData.timePeriod2.asChargeTime()
//                ]
//
//                try await networking.setBatteryTimes(deviceSN: deviceSN, times: times)
//                resetDirtyState()
//                alertContent = AlertContent(title: "Success", message: "battery_charge_schedule_settings_saved")
//                await setState(.inactive)
//            } catch let NetworkError.foxServerError(code, _) where code == 44096 {
//                alertContent = AlertContent(title: "Failed", message: "cannot_save_due_to_active_schedule")
//                await setState(.inactive)
//            } catch {
//                await setState(.error(error, "Could not save settings"))
//            }
//        }
    }

    func reset() {
        viewData = viewData.copy {
            $0.timePeriod1 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
            $0.timePeriod2 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
            $0.timePeriod3 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
        }
    }
}
