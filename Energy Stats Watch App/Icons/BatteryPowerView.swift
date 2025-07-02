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
                                .readSize { batterySize = $0 }

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
                        Text(battery.kW(2))
                    } else {
                        Text("xxxxx")
                            .redacted(reason: .placeholder)
                    }
                }
            },
            line2: {
                Group {
                    if let batterySOC {
                        Text(batterySOC, format: .percent)
                    } else {
                        Text(" ")
                    }
                }
            }
        )
    }
}

#Preview {
    BatteryPowerView(batterySOC: 1.0, battery: 8.4, iconScale: .large)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: -0.5, iconScale: .small)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: 0.5, iconScale: .small)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: nil, iconScale: .small)
}
