//
//  InverterSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct InverterSettingsView: View {
    let configManager: ConfigManaging
    let firmwareVersion: DeviceFirmwareVersion?

    var body: some View {
        Form {
            InverterChoiceView(viewModel: InverterChoiceViewModel(configManager: configManager))

            InverterFirmwareVersionsView(viewModel: firmwareVersion)

            if let currentDevice = configManager.currentDevice.value {
                Section {
                    ESLabeledContent("Plant Name", value: currentDevice.plantName)
                    ESLabeledContent("Device Type", value: currentDevice.deviceType)
                    ESLabeledContent("Device ID", value: currentDevice.deviceID)
                    ESLabeledContent("Device Serial No.", value: currentDevice.deviceSN)
                    ESLabeledContent("Module Serial No.", value: currentDevice.moduleSN)
                    ESLabeledContent("Has Battery", value: currentDevice.battery != nil ? "true" : "false")
                    ESLabeledContent("Has Solar", value: currentDevice.hasPV ? "true" : "false")
                }
                .contentShape(Rectangle())
                .alertCopy(text(currentDevice))
            }
        }
    }

    func text(_ currentDevice: Device) -> String {
        [
            makePair("Plant Name", value: currentDevice.plantName),
            makePair("Device Type", value: currentDevice.deviceType),
            makePair("Device ID", value: currentDevice.deviceID),
            makePair("Device Serial No.", value: currentDevice.deviceSN),
            makePair("Module Serial No.", value: currentDevice.moduleSN),
            makePair("Has Battery", value: currentDevice.battery != nil ? "true" : "false"),
            makePair("Has Solar", value: currentDevice.hasPV ? "true" : "false")
        ]
        .compactMap { $0 }
        .joined(separator: "\n")
    }

    private func makePair(_ title: String, value: String?) -> String {
        "\(title) \(value ?? "unknown")"
    }
}

struct InverterSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InverterSettingsView(configManager: PreviewConfigManager(), firmwareVersion: .preview())
    }
}

struct ESLabeledContent: View {
    let title: String
    let value: String?

    init(_ title: String, value: String?) {
        self.title = title
        self.value = value
    }

    var body: some View {
        Group {
            if let value {
                if #available(iOS 16, *) {
                    LabeledContent(title, value: value)
                } else {
                    HStack {
                        Text(title)
                        Spacer()
                        Text(value)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
