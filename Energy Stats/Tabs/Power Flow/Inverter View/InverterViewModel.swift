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

    var id: String { device.deviceID }
}

class InverterViewModel: ObservableObject {
    private var configManager: ConfigManaging
    @Published var devices: [SelectableDevice] = []
    let temperatures: InverterTemperatures?

    init(configManager: ConfigManaging, temperatures: InverterTemperatures?) {
        self.configManager = configManager
        self.temperatures = temperatures

        updateDevices()
    }

    func updateDevices() {
//        let deviceList = configManager.devices ?? []
//        devices = deviceList.map {
//            SelectableDevice(device: $0, isSelected: configManager.selectedDeviceID == $0.deviceID)
//        }
    }

    func select(device: Device) {
        configManager.select(deviceSN: device.deviceSN)
        updateDevices()
    }

    var hasMultipleDevices: Bool {
        devices.count > 1
    }

    var deviceType: String? {
        configManager.currentDevice.value?.deviceType
    }

    var devicePlantName: String? {
        configManager.currentDevice.value?.plantName
    }

    var deviceDisplayName: String? {
        configManager.currentDevice.value?.deviceDisplayName
    }
}
