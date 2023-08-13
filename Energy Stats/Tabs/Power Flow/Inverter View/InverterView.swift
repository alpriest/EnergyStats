//
//  InverterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 13/08/2023.
//

import Energy_Stats_Core
import SwiftUI

extension VerticalAlignment {
    struct CustomAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[VerticalAlignment.bottom]
        }
    }

    static let myVerticalAlignment = VerticalAlignment(CustomAlignment.self)
}

extension Alignment {
    static let custom = Alignment(horizontal: .center, vertical: .myVerticalAlignment)
}

struct InverterView: View {
    @ObservedObject var viewModel: InverterViewModel
    let appTheme: AppTheme

    var body: some View {
        ZStack {
            InverterPath()
                .stroke(lineWidth: 4)
                .foregroundColor(Color("lines_notflowing"))

            VStack {
                if appTheme.showInverterTemperature {
                    Text("hidden")
                        .hidden()
                }

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
                        Text(viewModel.devices.first?.device.deviceDisplayName ?? "")
                    }
                }
                .background(Color("background"))

                if appTheme.showInverterTemperature {
                    HStack {
                        Text("1117.5c")
                        Text("1117.5c")
                    }
                    .background(Color("background"))
                }
            }
        }
    }
}

struct InverterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InverterView(viewModel: InverterViewModel(configManager: PreviewConfigManager()), appTheme: .mock(showInverterTemperature: true))
                .background(Color.gray.opacity(0.3))

            InverterView(viewModel: InverterViewModel(configManager: PreviewConfigManager()), appTheme: .mock(showInverterTemperature: false))
                .background(Color.gray.opacity(0.3))
        }
    }
}
