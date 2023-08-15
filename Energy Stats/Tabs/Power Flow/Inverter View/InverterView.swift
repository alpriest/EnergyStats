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
                (Text(value, format: .number) +
                    Text("℃"))
                    .font(.caption)
                Text(name.uppercased())
                    .font(.system(size: 8.0))
            }
        }
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
                // Vertical alignment
//                VStack(spacing: 0) {
                    InverterIconView()
                        .frame(width: 55, height: 40)
                        .padding(.bottom, 5)
                        .background(verticalDeviceDetail().offset(y: 40))
//                }
            } else {
                // Horizontal alignment
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
