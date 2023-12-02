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

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
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

    func save() {}

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
        let phases = schedule.pollcy.compactMap { $0.toSchedulePhase(workModes: workModes)}

        self.init(
            name: nil,
            phases: phases
        )
    }
}
