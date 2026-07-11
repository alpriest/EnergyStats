//
//  BatteryPowerView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 03/05/2024.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryPowerView: View {
    let batterySOC: Double?
    let battery: Double?
    let totalCharge: Double?
    let totalDischarge: Double?
    let iconScale: IconScale
    @State private var batterySize: CGSize = .zero

    var body: some View {
        FullPageStatusView(
            iconScale: iconScale,
            icon: {
                Group {
                    if iconScale.isLarge {
                        ZStack(alignment: .bottom) {
                            Image(systemName: "minus.plus.batteryblock.fill")
                                .font(iconScale.iconFont)
                                .opacity(0)
                                .background(
                                    Color.clear.onGeometryChange(for: CGSize.self) { proxy in
                                        proxy.size
                                    } action: {
                                        batterySize = $0
                                    }
                                )

                            Color.iconDisabled

                            if let batterySOC = batterySOC {
                                battery.tintColor
                                    .opacity(0.5)
                                    .frame(height: batterySize.height * batterySOC)
                                    .padding(.bottom, 7)
                            }
                        }
                        .mask(
                            Image(systemName: "minus.plus.batteryblock.fill")
                                .font(iconScale.iconFont)
                        )
                    } else {
                        Image(systemName: "minus.plus.batteryblock.fill")
                            .font(iconScale.iconFont)
                            .foregroundStyle(battery == nil ? Color.iconDisabled : battery.tintColor)
                    }
                }
            },
            line1: {
                Group {
                    if let battery {
                        line1Text(battery: battery, batterySOC: batterySOC)
                    } else {
                        Text("xxxxx")
                            .redacted(reason: .placeholder)
                    }
                }
            },
            line2: {
                Group {
                    if let batterySOC {
                        line2Text(batterySOC: batterySOC)
                    } else {
                        Text(" ")
                    }
                }
            }
        )
    }
    
    private func line1Text(battery: Double, batterySOC: Double?) -> some View {
        Group {
            switch iconScale {
            case .small:
                Text(battery.kW(2))
            case .large:
                HStack {
                    Text(battery.kW(2))
                    
                    if let batterySOC {
                        Text(batterySOC, format: .percent)
                    }
                }
            }
        }
    }
    
    private func line2Text(batterySOC: Double) -> some View {
        Group {
            switch iconScale {
            case .small:
                Text(batterySOC, format: .percent)
            case .large:
                if let totalCharge, let totalDischarge {
                    HStack(spacing: 2) {
                        Text(totalCharge.roundedToString(decimalPlaces: 1))
                            .foregroundStyle(Color.linesNegative)
                        Text("/")
                            .foregroundStyle(Color.linesNotFlowing)
                        Text(totalDischarge.kWh(1))
                            .foregroundStyle(Color.linesPositive)
                    }
                    .monospacedDigit()
                }
            }
        }
    }
}

#Preview {
    BatteryPowerView(batterySOC: 1.0, battery: -0.001, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .large)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: -0.5, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .small)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: 0.5, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .small)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: nil, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .small)
}
