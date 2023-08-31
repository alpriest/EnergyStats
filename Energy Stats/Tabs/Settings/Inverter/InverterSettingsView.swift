//
//  InverterSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct InverterSettingsView: View {
    let networking: Networking
    let configManager: ConfigManaging
    let firmwareVersion: DeviceFirmwareVersion?
    @Binding var showInverterTemperature: Bool
    @Binding var showInverterIcon: Bool
    @Binding var shouldInvertCT2: Bool

    var body: some View {
        Form {
            InverterChoiceView(viewModel: InverterChoiceViewModel(configManager: configManager))

            NavigationLink("Configure Work Mode") {
                InverterWorkModeView(networking: networking, config: configManager)
            }

            Toggle(isOn: $showInverterTemperature) {
                Text("Show inverter temperatures")
            }

            Toggle(isOn: $showInverterIcon) {
                Text("Show inverter icon")
            }

            Section {
                Toggle(isOn: $shouldInvertCT2) {
                    Text("Invert CT2 values when detected")
                }
            } header: {
                Text("Advanced")
            } footer: {
                Text("invert_ct2_footnote")
            }

            InverterFirmwareVersionsView(viewModel: firmwareVersion)

            if let currentDevice = configManager.currentDevice.value {
                Section {
                    ESLabeledText("Plant Name", value: currentDevice.plantName)
                    ESLabeledText("Device Type", value: currentDevice.deviceType)
                    ESLabeledText("Device ID", value: currentDevice.deviceID)
                    ESLabeledText("Device Serial No.", value: currentDevice.deviceSN)
                    ESLabeledText("Module Serial No.", value: currentDevice.moduleSN)
                    ESLabeledText("Has Battery", value: currentDevice.battery != nil ? "true" : "false")
                    ESLabeledText("Has Solar", value: currentDevice.hasPV ? "true" : "false")
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

#if DEBUG
struct InverterSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InverterSettingsView(
            networking: DemoNetworking(),
            configManager: PreviewConfigManager(),
            firmwareVersion: .preview(),
            showInverterTemperature: .constant(true),
            showInverterIcon: .constant(true),
            shouldInvertCT2: .constant(true)
        )
    }
}
#endif

struct ESLabeledContent<Content: View>: View {
    let title: String
    let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        Group {
            if #available(iOS 16, *) {
                LabeledContent(title, content: content)
            } else {
                HStack {
                    Text(title)
                    Spacer()
                    content()
                }
            }
        }
    }
}

struct ESLabeledText: View {
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
