//
//  ScheduleSummaryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class ScheduleSummaryViewModel: ObservableObject, HasLoadState, HasAlertContent {
    let networking: Networking
    let configManager: ConfigManaging
    let templateStore: TemplateStoring
    @Published var state: LoadState = .inactive
    @Published var templates: [ScheduleTemplate] = []
    @Published var alertContent: AlertContent?
    @Published var schedule: Schedule?
    @Published var schedulerEnabled: Bool = false {
        didSet {
            if case .inactive = self.state {
                Task { await setSchedulerFlag() }
            }
        }
    }

    private var hasPreLoaded = false

    init(networking: Networking, configManager: ConfigManaging, templateStore: TemplateStoring) {
        self.networking = networking
        self.configManager = configManager
        self.templateStore = templateStore
    }

    @MainActor
    func preload() async {
        guard
            let device = configManager.currentDevice.value,
            state == .inactive
        else { return }

        defer {
            hasPreLoaded = true
        }

        await setState(.active(.loading))

        do {
            let flags = try await networking.fetchSchedulerFlag(deviceSN: device.deviceSN)
            if !flags.support {
                let firmwareVersions: DeviceFirmwareVersion?
                if let response = try? await networking.fetchDevice(deviceSN: device.deviceSN) {
                    firmwareVersions = DeviceFirmwareVersion(master: response.masterVersion, slave: response.slaveVersion, manager: response.managerVersion)
                } else {
                    firmwareVersions = nil
                }

                let message = String(key: .schedulesUnsupported, arguments: [device.deviceDisplayName, firmwareVersions?.manager ?? ""])
                await setState(.error(nil, message))
            } else {
                await setState(.inactive)
            }
        } catch {
            await setState(.error(error, error.localizedDescription))
        }
    }

    @MainActor
    func load() async {
        guard
            let deviceSN = configManager.currentDevice.value?.deviceSN,
            state == .inactive
        else { return }

        if !self.hasPreLoaded {
            await self.preload()
            if case .error = self.state {
                return
            }
        }
        await setState(.active(.loading))

        do {
            self.templates = self.templateStore.load()
            let scheduleResponse = try await networking.fetchCurrentSchedule(deviceSN: deviceSN)
            self.schedulerEnabled = scheduleResponse.enable.boolValue

            self.schedule = Schedule(scheduleResponse: scheduleResponse)
            if let schedule, schedule.supportsMaxSOC() {
                self.configManager.setDeviceSupports(capability: .scheduleMaxSOC, deviceSN: deviceSN)
            }
            if scheduleResponse.supportsPeakShaving() {
                self.configManager.setDeviceSupports(capability: .peakShaving, deviceSN: deviceSN)
            }
            await self.setState(.inactive)
        } catch {
            await self.setState(.error(error, error.localizedDescription))
        }
    }

    @MainActor
    func setSchedulerFlag() async {
        guard
            let deviceSN = configManager.currentDevice.value?.deviceSN,
            state == .inactive
        else { return }

        do {
            if self.schedulerEnabled {
                await setState(.active(.activating))
            } else {
                await setState(.active(.deactivating))
            }

            try await self.networking.setScheduleFlag(deviceSN: deviceSN, enable: self.schedulerEnabled)
            await self.setState(.inactive)
        } catch NetworkError.foxServerError(44098, _) {
            await setState(.inactive)
            await setAlertContent(AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: "fox_cloud_44098")))
        } catch {
            await self.setState(.error(error, error.localizedDescription))
        }
    }

    func activate(_ template: ScheduleTemplate) async {
        guard let deviceSN = configManager.currentDevice.value?.deviceSN else { return }
        let schedule = template.asSchedule()
        guard schedule.isValid() else {
            await setAlertContent(AlertContent(title: "error_title", message: "overlapping_time_periods"))
            return
        }

        await setState(.active(.activating))

        do {
            try await self.networking.saveSchedule(deviceSN: deviceSN, schedule: schedule)

            Task { @MainActor in
                await setState(.inactive)
                await self.load()
                self.alertContent = AlertContent(
                    title: "Success",
                    message: "inverter_charge_schedule_settings_saved"
                )
            }
        } catch NetworkError.foxServerError(44098, _) {
            await setState(.inactive)
            await setAlertContent(AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: "fox_cloud_44098")))
        } catch {
            await setState(.inactive)
            await setAlertContent(AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription)))
        }
    }
}

extension SchedulePhaseNetworkModel {
    func toSchedulePhase() -> SchedulePhase? {
        SchedulePhase(
            start: Time(hour: startHour, minute: startMinute),
            end: Time(hour: endHour, minute: endMinute),
            mode: workMode,
            minSocOnGrid: minSocOnGrid,
            forceDischargePower: fdPwr ?? 0,
            forceDischargeSOC: fdSoc,
            maxSOC: maxSoc,
            color: Color.scheduleColor(named: workMode)
        )
    }
}

extension Schedule {
    func supportsMaxSOC() -> Bool {
        phases.anySatisfy { $0.maxSOC != nil }
    }

    init(scheduleResponse: ScheduleResponse) {
        self.init(phases: scheduleResponse.groups
            .filter { $0.enable == 1 }
            .compactMap { $0.toSchedulePhase() })
    }
}

private extension ScheduleResponse {
    func supportsPeakShaving() -> Bool {
        workmodes.contains(where: { $0 == WorkMode.PeakShaving })
    }
}
