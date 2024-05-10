//
//  ScheduleSummaryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class ScheduleSummaryViewModel: ObservableObject, HasLoadState {
    let networking: Networking
    let config: ConfigManaging
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

    init(networking: Networking, config: ConfigManaging, templateStore: TemplateStoring) {
        self.networking = networking
        self.config = config
        self.templateStore = templateStore
    }

    @MainActor
    func preload() async {
        guard
            let device = config.currentDevice.value,
            state == .inactive
        else { return }

        defer {
            hasPreLoaded = true
        }

        setState(.active("Loading"))

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
                setState(.error(nil, message))
            } else {
                setState(.inactive)
            }
        } catch {
            setState(.error(error, error.localizedDescription))
        }
    }

    @MainActor
    func load() async {
        guard
            let deviceSN = config.currentDevice.value?.deviceSN,
            state == .inactive
        else { return }

        if !self.hasPreLoaded {
            await self.preload()
            if case .error = self.state {
                return
            }
        }
        setState(.active("Loading"))

        do {
            self.templates = templateStore.load()
            let scheduleResponse = try await networking.fetchCurrentSchedule(deviceSN: deviceSN)
            self.schedulerEnabled = scheduleResponse.enable.boolValue

            self.schedule = Schedule(phases: scheduleResponse.groups.compactMap { $0.toSchedulePhase() })
            self.setState(.inactive)
        } catch {
            self.setState(.error(error, error.localizedDescription))
        }
    }

    @MainActor
    func setSchedulerFlag() async {
        guard
            let deviceSN = config.currentDevice.value?.deviceSN,
            state == .inactive
        else { return }

        do {
            if self.schedulerEnabled {
                setState(.active("Activating"))
            } else {
                setState(.active("Deactivating"))
            }

            try await self.networking.setScheduleFlag(deviceSN: deviceSN, enable: self.schedulerEnabled)
            self.setState(.inactive)
        } catch {
            self.setState(.error(error, error.localizedDescription))
        }
    }

    func activate(_ template: ScheduleTemplate) async {
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
        let schedule = template.asSchedule()
        guard schedule.isValid() else {
            self.alertContent = AlertContent(title: "error_title", message: "overlapping_time_periods")
            return
        }

        setState(.active("Activating"))

        do {
            try await self.networking.saveSchedule(deviceSN: deviceSN, schedule: schedule)

            Task { @MainActor in
                setState(.inactive)
                await load()
                self.alertContent = AlertContent(
                    title: "Success",
                    message: "inverter_charge_schedule_settings_saved"
                )
            }
        } catch {
            setState(.inactive)
            self.alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
        }
    }
}

extension SchedulePhaseResponse {
    func toSchedulePhase() -> SchedulePhase? {
        SchedulePhase(
            start: Time(hour: startHour, minute: startMinute),
            end: Time(hour: endHour, minute: endMinute),
            mode: workMode,
            minSocOnGrid: minSocOnGrid,
            forceDischargePower: fdPwr ?? 0,
            forceDischargeSOC: fdSoc,
            color: Color.scheduleColor(named: workMode)
        )
    }
}
