//
//  ScheduleViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import Foundation

class ScheduleViewModel: ObservableObject {
    let networking: FoxESSNetworking
    let config: ConfigManaging
    @Published var schedule: Schedule?
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
    }

    func load() {
        Task { @MainActor in
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            do {
                let flag = try await networking.fetchSchedulerFlag(deviceSN: deviceSN)
                if flag.support {
                    schedule = .preview()
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
}
