//
//  InverterFirmwareVersionsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct InverterFirmwareVersionsView: View {
    let viewModel: DeviceFirmwareVersion?
    let device: Device

    var body: some View {
        Group {
            if let version = viewModel {
                Section {
                    ESLabeledText("Model", value: device.deviceType)
                    ESLabeledText("Manager", value: version.manager)
                    ESLabeledText("Slave", value: version.slave)
                    ESLabeledText("Master", value: version.master)
                } header: {
                    Text("Firmware Versions")
                } footer: {
                    Link(destination: URL(string: "https://foxesscommunity.com/viewforum.php?f=29")!) {
                        HStack {
                            Text("Find out more")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .alertCopy(text(version))
            }
        }
    }

    func text(_ version: DeviceFirmwareVersion) -> String {
        "Manager: \(version.manager) Slave: \(version.slave) Master: \(version.master)"
    }
}

#if DEBUG
struct InverterFirmwareVersionsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            InverterFirmwareVersionsView(
                viewModel: DeviceFirmwareVersion.preview(),
                device: Device.preview()
            )
        }
    }
}
#endif
