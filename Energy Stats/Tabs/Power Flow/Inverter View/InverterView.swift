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
        if let value {
            VStack(alignment: .center) {
                Text(formattedValue + "℃")
                    .font(.caption)
                Text(name.uppercased())
                    .font(.system(size: 8.0))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Inverter \(name) temperature \(formattedValue) ℃")
        }
    }

    var formattedValue: String {
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
                    .frame(width: 55, height: 60)
                    .padding(5)
                    .accessibilityHidden(true)

                verticalDeviceDetail().offset(y: 45)
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
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.deviceType)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.bordered)
            } else {
                if appTheme.showInverterTemperature {
                    Text(viewModel.devices.first?.device.deviceDisplayName ?? "")
                        .padding(2)
                }
            }
        }
        .background(Color("background"))
    }
}

struct InverterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InverterView(viewModel: InverterViewModel(configManager: PreviewConfigManager(), temperatures: InverterTemperatures.any()), appTheme: .mock(showInverterTemperature: true))
                .background(Color.gray.opacity(0.3))

            InverterView(viewModel: InverterViewModel(configManager: PreviewConfigManager(), temperatures: InverterTemperatures.any()), appTheme: .mock(showInverterTemperature: false))
                .background(Color.gray.opacity(0.3))
        }
    }
}

extension InverterTemperatures {
    static func any() -> InverterTemperatures {
        InverterTemperatures(ambient: 35.2, inverter: 22.4)
    }
}
