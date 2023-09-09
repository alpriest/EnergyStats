//
//  InverterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 13/08/2023.
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

struct InverterTemperatureView: View {
    let value: Double?
    let name: String

    var body: some View {
        if let formattedValue {
            VStack(alignment: .center) {
                Text(formattedValue + "℃")
                    .font(.caption)
                Text(name.uppercased())
                    .font(.system(size: 8.0))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("accessibility.inverter") + Text(" \(name) ") + Text("accessibility.temperature") + Text(" \(formattedValue) ℃"))
        }
    }

    var formattedValue: String? {
        guard let value else { return "" }

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}

struct InverterView: View {
    @ObservedObject var viewModel: InverterViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let appTheme: AppTheme

    var body: some View {
        ZStack {
            InverterPath()
                .stroke(lineWidth: 4)
                .foregroundColor(Color("lines_notflowing"))

            if verticalSizeClass == .regular {
                // Portrait
                InverterIconView()
                    .frame(width: 50, height: 55)
                    .padding(5)
                    .accessibilityHidden(true)
                    .opacity(appTheme.showInverterIcon ? 1 : 0)

                verticalDeviceDetail().offset(y: appTheme.showInverterIcon ? 45 : 0)
            } else {
                // Landscape
                HStack {
                    deviceNameSelector()

                    if appTheme.showInverterTemperature, let temperatures = viewModel.temperatures {
                        HStack {
                            InverterTemperatureView(value: temperatures.ambient, name: "internal")
                            InverterTemperatureView(value: temperatures.inverter, name: "external")
                        }
                        .background(Color("background"))
                    }
                }
            }
        }
    }

    @ViewBuilder
    func verticalDeviceDetail() -> some View {
        VStack {
            if appTheme.showInverterTemperature {
                Text("hidden")
                    .hidden()
            }

            deviceNameSelector()

            if appTheme.showInverterTemperature, let temperatures = viewModel.temperatures {
                HStack {
                    InverterTemperatureView(value: temperatures.ambient, name: "internal")
                    InverterTemperatureView(value: temperatures.inverter, name: "external")
                }
                .background(Color("background"))
            }
        }
    }

    @ViewBuilder
    func deviceNameSelector() -> some View {
        Group {
            if viewModel.hasMultipleDevices {
                Menu {
                    ForEach(viewModel.devices) { selectableDevice in
                        Button {
                            viewModel.select(device: selectableDevice.device)
                        } label: {
                            Label(selectableDevice.device.deviceDisplayName,
                                  systemImage: selectableDevice.isSelected ? "checkmark" : "")

                            if appTheme.showInverterPlantName {
                                OptionalView(selectableDevice.device.plantName) {
                                    Text($0)
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                } label: {
                    VStack {
                        HStack {
                            VStack {
                                if appTheme.showInverterTypeNameOnPowerFlow {
                                    Text(viewModel.deviceType)
                                }
                                if appTheme.showInverterPlantName {
                                    OptionalView(viewModel.devicePlantName) {
                                        Text($0)
                                            .font(.caption2)
                                    }
                                }
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                        }
                    }
                }
                .buttonStyle(.bordered)
            } else {
                VStack {
                    if appTheme.showInverterTypeNameOnPowerFlow {
                        Text(viewModel.devices.first?.device.deviceDisplayName ?? "")
                    }

                    if appTheme.showInverterPlantName {
                        OptionalView(viewModel.devicePlantName) {
                            Text($0)
                                .font(.caption2)
                        }
                    }
                }
                .padding(2)
            }
        }
        .background(Color("background"))
    }
}

struct InverterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InverterView(viewModel: InverterViewModel(configManager: PreviewConfigManager(),
                                                      temperatures: InverterTemperatures.any()),
                         appTheme: .mock().copy(showInverterTemperature: true, showInverterPlantName: true))
                .background(Color.gray.opacity(0.3))

            InverterView(viewModel: InverterViewModel(configManager: PreviewConfigManager(),
                                                      temperatures: InverterTemperatures.any()),
                         appTheme: .mock().copy(showInverterTemperature: false))
                .background(Color.gray.opacity(0.3))
        }
    }
}

extension InverterTemperatures {
    static func any() -> InverterTemperatures {
        InverterTemperatures(ambient: 35.2, inverter: 22.4)
    }
}
