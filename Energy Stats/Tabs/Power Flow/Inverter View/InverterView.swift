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

struct InverterView: View {
    @ObservedObject var viewModel: InverterViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject var alertManager: BannerAlertManager
    @State private var alertContent: AlertContent?
    let appSettings: AppSettings

    var body: some View {
        ZStack {
            InverterPath()
                .stroke(lineWidth: 4)
                .foregroundColor(Color.linesNotFlowing)

            InverterIconView(deviceFaulty: viewModel.hasFault)
                .id(viewModel.deviceState)
                .frame(width: 50, height: 55)
                .padding(5)
                .accessibilityHidden(true)
                .opacity(appSettings.showInverterIcon ? 1 : 0)

            AdaptiveStackView {
                deviceNameSelector()

                if appSettings.showInverterTemperature, let temperatures = viewModel.temperatures {
                    HStack {
                        TemperatureView(value: temperatures.ambient, name: "internal", accessibilityName: "accessibility.inverter", showName: true) // TODO: Verify
                        TemperatureView(value: temperatures.inverter, name: "external", accessibilityName: "accessibility.inverter", showName: true) // TODO: Verify
                    }
                    .background(Color.background)
                }
            }
            .offset(y: verticalSizeClass == .regular && appSettings.showInverterIcon ? 55 : 0)
        }
        .if(viewModel.hasFault) {
            $0.onTapGesture {
                alertContent = AlertContent(title: nil, message: LocalizedStringKey(stringLiteral: viewModel.faultsMessage))
            }
        }
        .alert(alertContent: $alertContent)
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
                            Label(selectableDevice.device.deviceSelectorName,
                                  systemImage: selectableDevice.isSelected ? "checkmark" : "")

                            OptionalView(selectableDevice.device.deviceType) {
                                Text($0)
                                    .font(.caption2)
                            }
                        }
                    }
                } label: {
                    VStack {
                        HStack {
                            VStack {
                                OptionalView(viewModel.deviceStationName) {
                                    Text($0)
                                        .font(.caption2)
                                }
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(Color.textNotFlowing)

                        if appSettings.showInverterTypeName {
                            OptionalView(viewModel.deviceType) {
                                Text($0)
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .accessibilityLabel(viewModel.deviceSelectorAccessibilityLabel)
                .buttonStyle(.bordered)
                .padding(.top, 5)
                .background(Color.background)
            } else {
                VStack {
                    if appSettings.showInverterStationName {
                        OptionalView(viewModel.deviceStationName) {
                            Text($0)
                                .font(.caption2)
                        }
                    }

                    if appSettings.showInverterTypeName {
                        OptionalView(viewModel.deviceType) {
                            Text($0)
                                .font(.caption2)
                        }
                    }
                }
                .padding(2)
                .if(appSettings.showInverterStationName || appSettings.showInverterTypeName) {
                    $0.background(Color.background)
                }
            }
        }
    }
}

struct InverterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InverterView(viewModel: InverterViewModel(configManager: ConfigManager.preview(),
                                                      temperatures: InverterTemperatures.any(),
                                                      deviceState: .online,
                                                      faults: []),
                         appSettings: .mock().copy(showInverterTemperature: true, showInverterStationName: true))
                .background(Color.gray.opacity(0.3))

            InverterView(viewModel: InverterViewModel(configManager: ConfigManager.preview(),
                                                      temperatures: InverterTemperatures.any(),
                                                      deviceState: .offline,
                                                      faults: ["No Utility", "Grid Voltage Fault", "Grid Frequency Fault"]),
                         appSettings: .mock().copy(showInverterTemperature: false))
                .background(Color.gray.opacity(0.3))
        }
    }
}

extension InverterTemperatures {
    static func any() -> InverterTemperatures {
        InverterTemperatures(ambient: 35.2, inverter: 22.4)
    }
}
