//
//  FirmwareLoadingView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/01/2025.
//

import Energy_Stats_Core
import SwiftUI

struct FirmwareLoadingView: View {
    @State private var loading = false
    @State private var firmwareVersions: DeviceFirmwareVersion? = nil
    let configManager: ConfigManaging
    let networking: Networking

    var body: some View {
        if let firmwareVersions, let device = configManager.currentDevice.value {
            InverterFirmwareVersionsView(viewModel: firmwareVersions, device: device)
        } else if let selectedDeviceSN = configManager.selectedDeviceSN {
            if loading {
                HStack {
                    Text("Loading")
                    Spacer()
                    ProgressView()
                }
            } else {
                Button {
                    Task {
                        defer {
                            loading = false
                        }

                        loading = true
                        if let response = try? await networking.fetchDevice(deviceSN: selectedDeviceSN) {
                            firmwareVersions = DeviceFirmwareVersion(master: response.masterVersion, slave: response.slaveVersion, manager: response.managerVersion)
                        }
                    }
                } label: {
                    Text("Load firmware versions")
                }
            }
        }
    }
}
