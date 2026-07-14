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
                            let clampedSOC = min(max(batterySOC, 0), 1)
                            let bottomPadding = batterySize.height * 0.073
                            let topPadding = batterySize.height * 0.06
                            let fillableHeight = max(0, batterySize.height - topPadding - bottomPadding)

                            battery.tintColor
                                .opacity(0.5)
                                .frame(height: fillableHeight * clampedSOC)
                                .padding(.bottom, bottomPadding)
                        }
                    }
                    .mask(
                        Image(systemName: "minus.plus.batteryblock.fill")
                            .font(iconScale.iconFont)
                    )
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
                        Text(totalDischarge.roundedToString(decimalPlaces: 1))
                            .foregroundStyle(Color.linesNegative)
                        Text("/")
                            .foregroundStyle(Color.linesNotFlowing)
                        Text(totalCharge.kWh(1))
                            .foregroundStyle(Color.linesPositive)
                    }
                    .monospacedDigit()
                }
            }
        }
    }
}

#Preview {
    BatteryPowerView(batterySOC: 0.5, battery: -0.5, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .small)
}

#Preview {
    BatteryPowerView(batterySOC: 1.0, battery: -0.001, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .large)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: 0.5, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .small)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: nil, totalCharge: 1.0, totalDischarge: 2.0, iconScale: .small)
}
