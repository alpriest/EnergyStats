//
//  InverterPath.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct InverterPath: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.height / 2.0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2.0))
            path.move(to: CGPoint(x: rect.width, y: rect.height / 2.0))
        }
    }
}

struct SelectableDevice: Identifiable {
    let device: Device
    let isSelected: Bool

    var id: String { device.deviceID }
}

class InverterViewModel: ObservableObject {
    private var configManager: ConfigManaging
    @Published var devices: [SelectableDevice] = []

    init(configManager: ConfigManaging) {
        self.configManager = configManager

        updateDevices()
    }

    func updateDevices() {
        let deviceList = configManager.devices ?? []
        devices = deviceList.map {
            SelectableDevice(device: $0, isSelected: configManager.selectedDeviceID == $0.deviceID)
        }
    }

    func select(device: Device) {
        configManager.select(device: device)
        updateDevices()
    }

    var hasMultipleDevices: Bool {
        devices.count > 1
    }

    var deviceType: String {
        configManager.currentDevice.value?.deviceType ?? ""
    }
}
