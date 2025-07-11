//
//  EditTemplateViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/12/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class EditTemplateViewModel: ObservableObject, HasLoadState, HasAlertContent {
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var schedule: Schedule?
    @Published var name: String?
    private let config: ConfigManaging
    private let modes: [WorkMode] = WorkMode.allCases
    private let templateStore: TemplateStoring
    private let networking: Networking
    private var template: ScheduleTemplate

    init(networking: Networking, templateStore: TemplateStoring, config: ConfigManaging, template: ScheduleTemplate) {
        self.networking = networking
        self.templateStore = templateStore
        self.config = config
        self.template = template
        self.schedule = template.asSchedule()
        self.name = template.name
    }

    func saveTemplate(onCompletion: @escaping () -> Void) {
        guard let schedule else { return }
        template = template.copy(phases: schedule.phases)
        guard template.asSchedule().isValid() else {
            alertContent = AlertContent(title: "error_title", message: "overlapping_time_periods")
            return
        }

        templateStore.save(template: template)

        alertContent = AlertContent(
            title: "Success",
            message: "Your template was saved",
            onDismiss: onCompletion
        )
    }

    func deleteTemplate(onCompletion: @escaping () -> Void) {
        templateStore.delete(template: template)

        alertContent = AlertContent(
            title: "Success",
            message: "inverter_charge_template_deleted",
            onDismiss: onCompletion
        )
    }

    func activate(onCompletion: @escaping () -> Void) {
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
        guard let schedule else { return }
        guard schedule.isValid() else {
            alertContent = AlertContent(title: "error_title", message: "overlapping_time_periods")
            return
        }

        Task { @MainActor in
            await setState(.active(.saving))

            do {
                await setState(.active(.saving))
                try await networking.saveSchedule(deviceSN: deviceSN, schedule: schedule)

                await setState(.active(.activating))
                try await networking.setScheduleFlag(deviceSN: deviceSN, enable: true)

                Task { @MainActor in
                    await setState(.inactive)
                    await setAlertContent(AlertContent(
                        title: "Success",
                        message: "Your template was activated"
                    ))
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

    func duplicate(as name: String) {
        templateStore.duplicate(template: template, named: name)
    }

    func rename(as name: String) {
        templateStore.rename(template: template, to: name)
        self.name = name
    }

    func autoFillScheduleGaps() {
        guard let schedule else { return }
        guard let mode = modes.first else { return }
        guard let device = config.currentDevice.value else { return }

        self.schedule = SchedulePhaseHelper.appendPhasesInGaps(
            to: schedule,
            mode: mode,
            device: device,
            initialiseMaxSOC: config.getDeviceSupports(capability: .scheduleMaxSOC, deviceSN: device.deviceSN)
        )
    }

    func addNewTimePeriod() {
        guard let schedule else { return }
        guard let device = config.currentDevice.value else { return }

        self.schedule = SchedulePhaseHelper.addNewTimePeriod(
            to: schedule,
            device: device,
            initialiseMaxSOC: config.getDeviceSupports(capability: .scheduleMaxSOC, deviceSN: device.deviceSN)
        )
    }

    func updatedPhase(_ phase: SchedulePhase) {
        guard let schedule else { return }

        self.schedule = SchedulePhaseHelper.updated(phase: phase, on: schedule)
    }

    func deletedPhase(_ id: String) {
        guard let schedule else { return }

        self.schedule = SchedulePhaseHelper.deleted(phaseID: id, on: schedule)
    }
}
