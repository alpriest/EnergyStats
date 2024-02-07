//
//  ScheduleSummaryViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class ScheduleSummaryViewModel: ObservableObject {
    let networking: FoxESSNetworking
    let config: ConfigManaging
    @Published var state: LoadState = .inactive
//    @Published var templates: [ScheduleTemplateSummary] = []
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

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
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

        self.state = .active("Loading")

        do {
            let flags = try await networking.openapi_fetchSchedulerFlag(deviceSN: device.deviceSN)
            if !flags.support {
                let firmwareVersions: DeviceFirmwareVersion?
                if let response = try? await networking.openapi_fetchDevice(deviceSN: device.deviceSN) {
                    firmwareVersions = DeviceFirmwareVersion(master: response.masterVersion, slave: response.slaveVersion, manager: response.managerVersion)
                } else {
                    firmwareVersions = nil
                }

                let message = String(key: .schedulesUnsupported, arguments: [device.deviceDisplayName, firmwareVersions?.manager ?? ""])
                self.state = .error(nil, message)
            } else {
                self.state = .inactive
            }
        } catch {
            self.state = LoadState.error(error, error.localizedDescription)
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
        self.state = .active("Loading")

        do {
            let scheduleResponse = try await networking.openapi_fetchCurrentSchedule(deviceSN: deviceSN)
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
                self.state = .active("Activating")
            } else {
                self.state = .active("Deactivating")
            }

            try await self.networking.openapi_setScheduleFlag(deviceSN: deviceSN, enable: self.schedulerEnabled)
            self.setState(.inactive)
        } catch {
            self.setState(.error(error, error.localizedDescription))
        }
    }

    private func setState(_ state: LoadState) {
        Task { @MainActor in
            self.state = state
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
