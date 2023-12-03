//
//  ScheduleViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class ScheduleViewModel: ObservableObject {
    let networking: FoxESSNetworking
    let config: ConfigManaging
    @Published var schedule: Schedule?
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var modes: [SchedulerModeResponse] = []
    @Published var enabled: Bool = false
    @Published var deviceName: String = ""

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        deviceName = config.currentDevice.value?.deviceDisplayName ?? "Unknown device"
    }

    func load() {
        Task { @MainActor [self] in
            guard
                let deviceSN = config.currentDevice.value?.deviceSN,
                let deviceID = config.currentDevice.value?.deviceID
            else { return }
            guard schedule == nil else { return }

            do {
                let flag = try await networking.fetchSchedulerFlag(deviceSN: deviceSN)
                if flag.support {
                    self.modes = try await networking.fetchScheduleModes(deviceID: deviceID)
                    let scheduleResponse = try await networking.fetchSchedule(deviceSN: deviceSN)

                    self.schedule = Schedule(schedule: scheduleResponse, workModes: self.modes)
                    self.enabled = scheduleResponse.enable
                } else {
                    alertContent = AlertContent(
                        title: "Not supported",
                        message: "Schedules are not supported on this inverter. Please contact FoxESS support."
                    )
                }
            } catch {
                self.state = LoadState.error(error, error.localizedDescription)
            }
        }
    }

    func save() {
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
        guard let schedule else {
            alertContent = AlertContent(title: "error_title", message: "No schedule to save.")
            return
        }
        guard isValid() else {
            alertContent = AlertContent(title: "error_title", message: "Some of the phases overlap, please adjust and try again.")
            return
        }

        Task { @MainActor [self] in
            do {
                try await networking.saveSchedule(deviceSN: deviceSN)
                alertContent = AlertContent(
                    title: "Success",
                    message: "inverter_charge_schedule_settings_saved"
                )
            } catch {
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
            }
        }
    }

    func addNewPhase() {
        guard let schedule else { return }
        guard let mode = modes.first else { return }

        self.schedule = Schedule(
            name: schedule.name,
            phases: schedule.phases + [SchedulePhase(mode: mode)]
        )
    }

    func updated(phase updatedPhase: SchedulePhase) {
        guard let schedule else { return }

        self.schedule = Schedule(
            name: schedule.name,
            phases: schedule.phases.map {
                if $0.id == updatedPhase.id {
                    return updatedPhase
                } else {
                    return $0
                }
            }
        )
    }

    func deleted(id: String) {
        guard let schedule else { return }

        self.schedule = Schedule(
            name: schedule.name,
            phases: schedule.phases.compactMap {
                if $0.id == id {
                    return nil
                } else {
                    return $0
                }
            }
        )
    }
}

private extension ScheduleViewModel {
    func isValid() -> Bool {
        guard let schedule else { return false }
        for (index, phase) in schedule.phases.enumerated() {
            let phaseStart = phase.start.toMinutes()
            let phaseEnd = phase.end.toMinutes()

            // Check for overlap with other phases
            for otherPhase in schedule.phases[(index + 1)...] {
                let otherStart = otherPhase.start.toMinutes()
                let otherEnd = otherPhase.end.toMinutes()

                // Check if the time periods overlap
                if phaseStart < otherEnd && otherStart < phaseEnd {
                    return false
                }
            }
        }

        return true
    }
}

private extension SchedulePhaseResponse {
    func toSchedulePhase(workModes: [SchedulerModeResponse]) -> SchedulePhase? {
        SchedulePhase(
            start: Time(hour: startH, minute: startM),
            end: Time(hour: endH, minute: endM),
            mode: workModes.first { $0.key == workMode },
            forceDischargePower: fdpwr,
            forceDischargeSOC: fdsoc,
            batterySOC: soc,
            color: Color.scheduleColor(named: workMode)
        )
    }
}

private extension Schedule {
    init(schedule: ScheduleListResponse, workModes: [SchedulerModeResponse]) {
        let phases = schedule.pollcy.compactMap { $0.toSchedulePhase(workModes: workModes) }

        self.init(
            name: nil,
            phases: phases
        )
    }
}
