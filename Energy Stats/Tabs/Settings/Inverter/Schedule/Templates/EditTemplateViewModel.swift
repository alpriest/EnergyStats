//
//  EditTemplateViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/12/2023.
//

import Energy_Stats_Core
import Foundation

class EditTemplateViewModel: ObservableObject {
    @Published var state: LoadState = .inactive
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

    private func load() async {
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

    private func setState(_ state: LoadState) {
        Task { @MainActor in
            self.state = state
        }
    }
}
