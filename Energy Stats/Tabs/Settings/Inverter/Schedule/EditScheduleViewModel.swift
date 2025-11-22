//
//  ScheduleViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

struct EditScheduleViewData: Copiable {
    var schedule: Schedule

    func create(copying previous: EditScheduleViewData) -> EditScheduleViewData {
        .init(schedule: previous.schedule)
    }
}

class EditScheduleViewModel: ObservableObject, HasLoadState, HasAlertContent, ViewDataProviding {
    typealias ViewData = EditScheduleViewData
    
    private let networking: Networking
    private let configManager: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var viewData: ViewData
    @Published var isDirty = false
    var originalValue: ViewData?
    
    init(networking: Networking, configManager: ConfigManaging, schedule: Schedule) {
        self.networking = networking
        self.configManager = configManager
        let viewData = ViewData(schedule: schedule)
        self.originalValue = viewData
        self.viewData = viewData
    }

    func saveSchedule(onCompletion: @escaping () -> Void) async {
        guard let deviceSN = configManager.currentDevice.value?.deviceSN else { return }
        guard viewData.schedule.isValid() else {
            await setAlertContent(AlertContent(title: "error_title", message: "overlapping_time_periods"))
            return
        }

        await setState(.active(.saving))

        Task { [self] in
            do {
                try await networking.saveSchedule(deviceSN: deviceSN, schedule: viewData.schedule)

                await setState(.inactive)
                resetDirtyState()

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

        viewData = viewData.copy {
            $0.schedule = SchedulePhaseHelper.appendPhasesInGaps(
                to: viewData.schedule,
                mode: WorkMode.SelfUse,
                device: device,
                initialiseMaxSOC: configManager.getDeviceSupports(capability: .scheduleMaxSOC, deviceSN: device.deviceSN)
            )
        }
    }

    func addNewTimePeriod() {
        guard let device = configManager.currentDevice.value else { return }

        viewData = viewData.copy {
            $0.schedule = SchedulePhaseHelper.addNewTimePeriod(
                to: $0.schedule,
                device: device,
                initialiseMaxSOC: configManager.getDeviceSupports(capability: .scheduleMaxSOC, deviceSN: device.deviceSN)
            )
        }
    }

    func updatedPhase(_ phase: SchedulePhase) {
        viewData = viewData.copy {
            $0.schedule = SchedulePhaseHelper.updated(phase: phase, on: $0.schedule)
        }
    }

    func deletedPhase(_ id: String) {
        viewData = viewData.copy {
            $0.schedule = SchedulePhaseHelper.deleted(phaseID: id, on: $0.schedule)
        }
    }

    func retryNoOp() {}
}
