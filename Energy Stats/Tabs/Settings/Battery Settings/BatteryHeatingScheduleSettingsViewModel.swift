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
    var available: Bool
    var enabled: Bool
    var currentState: String?
    var timePeriod1: ChargeTimePeriod
    var timePeriod2: ChargeTimePeriod
    var timePeriod3: ChargeTimePeriod
    var startTemperature: Double
    var endTemperature: Double
    var minStartTemperature: Double
    var maxStartTemperature: Double
    var minEndTemperature: Double
    var maxEndTemperature: Double
    var summary: String

    func create(copying previous: BatteryHeatingScheduleSettingsViewData) -> BatteryHeatingScheduleSettingsViewData {
        BatteryHeatingScheduleSettingsViewData(
            available: previous.available,
            enabled: previous.enabled,
            timePeriod1: previous.timePeriod1,
            timePeriod2: previous.timePeriod2,
            timePeriod3: previous.timePeriod3,
            startTemperature: previous.startTemperature,
            endTemperature: previous.endTemperature,
            minStartTemperature: previous.minStartTemperature,
            maxStartTemperature: previous.maxStartTemperature,
            minEndTemperature: previous.minEndTemperature,
            maxEndTemperature: previous.maxEndTemperature,
            summary: previous.summary
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
        available: true,
        enabled: false,
        currentState: nil,
        timePeriod1: .init(start: Date(), end: Date(), enabled: false),
        timePeriod2: .init(start: Date(), end: Date(), enabled: false),
        timePeriod3: .init(start: Date(), end: Date(), enabled: false),
        startTemperature: 1,
        endTemperature: 10,
        minStartTemperature: 1.0,
        maxStartTemperature: 9.0,
        minEndTemperature: 10.0,
        maxEndTemperature: 15.0,
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
                let settings = try await networking.fetchBatteryHeatingSchedule(deviceSN: deviceSN)

                let timePeriod1 = ChargeTimePeriod(startTime: settings.period1Start, endTime: settings.period1End, enabled: settings.period1Enabled)
                let timePeriod2 = ChargeTimePeriod(startTime: settings.period2Start, endTime: settings.period2End, enabled: settings.period2Enabled)
                let timePeriod3 = ChargeTimePeriod(startTime: settings.period3Start, endTime: settings.period3End, enabled: settings.period3Enabled)

                let viewData = ViewData(
                    available: true,
                    enabled: settings.enabled,
                    currentState: settings.warmUpState,
                    timePeriod1: timePeriod1,
                    timePeriod2: timePeriod2,
                    timePeriod3: timePeriod3,
                    startTemperature: settings.startTemperature,
                    endTemperature: settings.endTemperature,
                    minStartTemperature: settings.minStartTemperature,
                    maxStartTemperature: settings.maxStartTemperature,
                    minEndTemperature: settings.minEndTemperature,
                    maxEndTemperature: settings.maxEndTemperature,
                    summary: generateSummary(
                        enabled: settings.enabled,
                        period1: timePeriod1,
                        period2: timePeriod2,
                        period3: timePeriod3,
                        startTemperature: settings.startTemperature,
                        endTemperature: settings.endTemperature
                    )
                )
                self.originalValue = viewData
                self.viewData = viewData

                await setState(.inactive)
            } catch NetworkError.foxServerError(41200, _) {
                self.viewData = viewData.copy { $0.available = false }
                await setState(.inactive)
            } catch {
                await setState(.error(error, String(key: .couldNotLoadHeatingSchedule)))
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            await setState(.active(.saving))

            do {
                try await networking.setBatteryHeatingSchedule(deviceSN: deviceSN,
                                                               enabled: viewData.enabled,
                                                               period1Start: viewData.timePeriod1.start.toTime(),
                                                               period1End: viewData.timePeriod1.end.toTime(),
                                                               period1Enabled: viewData.timePeriod1.enabled,
                                                               period2Start: viewData.timePeriod2.start.toTime(),
                                                               period2End: viewData.timePeriod2.end.toTime(),
                                                               period2Enabled: viewData.timePeriod2.enabled,
                                                               period3Start: viewData.timePeriod3.start.toTime(),
                                                               period3End: viewData.timePeriod3.end.toTime(),
                                                               period3Enabled: viewData.timePeriod3.enabled,
                                                               startTemperature: viewData.startTemperature,
                                                               endTemperature: viewData.endTemperature)
                resetDirtyState()
                alertContent = AlertContent(title: "Success", message: "battery_heating_schedule_settings_saved")
                await setState(.inactive)
            } catch {
                await setState(.error(error, String(key: .couldNotSaveHeatingSchedule)))
            }
        }
    }

    func reset() {
        viewData = viewData.copy {
            $0.timePeriod1 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
            $0.timePeriod2 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
            $0.timePeriod3 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
        }
    }

    func updateSummary() {
        viewData = viewData.copy {
            $0.summary = generateSummary(
                enabled: viewData.enabled,
                period1: viewData.timePeriod1,
                period2: viewData.timePeriod2,
                period3: viewData.timePeriod3,
                startTemperature: viewData.startTemperature,
                endTemperature: viewData.endTemperature
            )
        }
    }

    private func generateSummary(
        enabled: Bool,
        period1: ChargeTimePeriod,
        period2: ChargeTimePeriod,
        period3: ChargeTimePeriod,
        startTemperature: Double,
        endTemperature: Double
    ) -> String {
        guard enabled else {
            return String(key: .batteryHeaterNotEnabled)
        }

        let times = [
            period1.enabled ? period1 : nil,
            period2.enabled ? period2 : nil,
            period3.enabled ? period3 : nil
        ]
        .compactMap { $0 }
        .sorted { first, second in
            first.start < second.start
        }
        .map { $0.description }

        if times.isEmpty {
            return String(key: .batteryHeaterEnabledButNoTimesEnabled)
        }

        return String(key: .batteryHeaterEnabledWithTimes, arguments: range(startTemperature, endTemperature), times.commaSeperated())
    }

    private func range(_ lower: Double, _ upper: Double) -> String {
        String(key: .celsiusRange, arguments: lower.celsius, upper.celsius)
    }
}

extension [String] {
    func commaSeperated() -> String {
        self.joined(separator: ", ")
    }
}
