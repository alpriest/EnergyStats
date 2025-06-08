//
//  ScheduleViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class EditScheduleViewModel: ObservableObject, HasLoadState, HasAlertContent {
    @Published var schedule: Schedule
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    private let networking: Networking
    private let configManager: ConfigManaging

    init(networking: Networking, configManager: ConfigManaging, schedule: Schedule) {
        self.networking = networking
        self.configManager = configManager
        self.schedule = schedule
    }

    func saveSchedule(onCompletion: @escaping () -> Void) async {
        guard let deviceSN = configManager.currentDevice.value?.deviceSN else { return }
        guard schedule.isValid() else {
            await setAlertContent(AlertContent(title: "error_title", message: "overlapping_time_periods"))
            return
        }

        await setState(.active(.saving))

        Task { [self] in
            do {
                try await networking.saveSchedule(deviceSN: deviceSN, schedule: schedule)

                await setState(.inactive)

                Task { @MainActor in
                    alertContent = AlertContent(
                        title: "Success",
                        message: "inverter_charge_schedule_settings_saved",
                        onDismiss: onCompletion
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

    private func makeEmptySchedule() -> Schedule {
        Schedule(phases: [])
    }

    func autoFillScheduleGaps() {
        guard let device = configManager.currentDevice.value else { return }

        schedule = SchedulePhaseHelper.appendPhasesInGaps(
            to: schedule,
            mode: .SelfUse,
            device: device,
            initialiseMaxSOC: configManager.getDeviceSupports(capability: .scheduleMaxSOC, deviceSN: device.deviceSN)
        )
    }

    func addNewTimePeriod() {
        guard let device = configManager.currentDevice.value else { return }

        schedule = SchedulePhaseHelper.addNewTimePeriod(
            to: schedule,
            device: device,
            initialiseMaxSOC: configManager.getDeviceSupports(capability: .scheduleMaxSOC, deviceSN: device.deviceSN)
        )
    }

    func updatedPhase(_ phase: SchedulePhase) {
        schedule = SchedulePhaseHelper.updated(phase: phase, on: schedule)
    }

    func deletedPhase(_ id: String) {
        schedule = SchedulePhaseHelper.deleted(phaseID: id, on: schedule)
    }

    func unused() {}
}
