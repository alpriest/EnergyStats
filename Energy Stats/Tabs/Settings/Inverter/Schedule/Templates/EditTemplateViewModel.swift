//
//  EditTemplateViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/12/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class EditTemplateViewModel: ObservableObject {
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?
    @Published var schedule: Schedule?
    let networking: FoxESSNetworking
    let config: ConfigManaging
    let modes: [SchedulerModeResponse]
    let templateID: String

    init(networking: FoxESSNetworking, config: ConfigManaging, templateID: String, modes: [SchedulerModeResponse]) {
        self.networking = networking
        self.config = config
        self.modes = modes
        self.templateID = templateID

        Task {
            await load()
        }
    }

    func load() async {
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }

        do {
            let template = try await networking.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)

            Task { @MainActor in
                schedule = Schedule(name: template.templateName,
                                    phases: template.pollcy.compactMap {
                                        $0.toSchedulePhase(workModes: modes)
                                    },
                                    templateID: templateID)
            }
        } catch {
            setState(.error(error, error.localizedDescription))
        }
    }

    func saveTemplate(onCompletion: @escaping () -> Void) {
        guard let schedule else { return }
        guard let templateID = schedule.templateID else { return }
        guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
        guard schedule.isValid() else {
            alertContent = AlertContent(title: "error_title", message: "overlapping_time_periods")
            return
        }

        setState(.active("Saving"))

        Task { [self] in
            do {
                try await networking.saveScheduleTemplate(deviceSN: deviceSN,
                                                          template: ScheduleTemplate(id: templateID, phases: schedule.phases))

                Task { @MainActor in
                    self.state = .inactive
                    alertContent = AlertContent(
                        title: "Success",
                        message: "Template updated",
                        onDismiss: onCompletion
                    )
                }
            } catch {
                self.state = .inactive
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
            }
        }
    }

    func deleteTemplate(onCompletion: @escaping () -> Void) {
        setState(.active("Saving"))

        Task { [self] in
            do {
                try await networking.deleteScheduleTemplate(templateID: templateID)

                Task { @MainActor in
                    self.state = .inactive
                    alertContent = AlertContent(
                        title: "Success",
                        message: "inverter_charge_template_deleted",
                        onDismiss: onCompletion
                    )
                }
            } catch {
                self.state = .inactive
                alertContent = AlertContent(title: "error_title", message: LocalizedStringKey(stringLiteral: error.localizedDescription))
            }
        }
    }

    func autoFillScheduleGaps() {
        guard let schedule else { return }
        guard let mode = modes.first else { return }
        let minSOC = Int(config.currentDevice.value?.battery?.minSOC) ?? 10

        self.schedule = SchedulePhaseHelper.appendPhasesInGaps(to: schedule, mode: mode, soc: minSOC)
    }

    func addNewTimePeriod() {
        guard let schedule else { return }

        self.schedule = SchedulePhaseHelper.addNewTimePeriod(to: schedule, modes: modes)
    }

    func updatedPhase(_ phase: SchedulePhase) {
        guard let schedule else { return }

        self.schedule = SchedulePhaseHelper.updated(phase: phase, on: schedule)
    }

    func deletedPhase(_ id: String) {
        guard let schedule else { return }

        self.schedule = SchedulePhaseHelper.deleted(phaseID: id, on: schedule)
    }

    private func setState(_ state: LoadState) {
        Task { @MainActor in
            self.state = state
        }
    }
}

extension Int {
    init?(_ value: String?) {
        guard let value else {return nil}

        self.init(value)
    }
}
