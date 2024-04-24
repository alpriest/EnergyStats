//
//  InverterPath.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct SelectableDevice: Identifiable {
    let device: Device
    let isSelected: Bool

    var id: String { device.deviceSN }
}

class InverterViewModel: ObservableObject {
    private var configManager: ConfigManaging
    @Published var devices: [SelectableDevice] = []
    let temperatures: InverterTemperatures?
    let deviceState: DeviceState
    let faults: [String]

    init(configManager: ConfigManaging, temperatures: InverterTemperatures?, deviceState: DeviceState, faults: [String]) {
        self.configManager = configManager
        self.temperatures = temperatures
        self.deviceState = deviceState
        self.faults = faults

        updateDevices()
    }

    func updateDevices() {
        let deviceList = configManager.devices ?? []
        devices = deviceList.map {
            SelectableDevice(device: $0, isSelected: configManager.selectedDeviceSN == $0.deviceSN)
        }
    }

    func select(device: Device) {
        configManager.select(device: device)
        updateDevices()
    }

    var hasFault: Bool {
        !faults.isEmpty
    }

    var faultsMessage: String {
        faults.joined(separator: "\n")
    }

    var hasMultipleDevices: Bool {
        devices.count > 1
    }

    var deviceStationName: String? {
        configManager.currentDevice.value?.stationName
    }

    var deviceDisplayName: String? {
        configManager.currentDevice.value?.deviceDisplayName
    }

    var deviceType: String? {
        configManager.currentDevice.value?.deviceType
    }
}
