//
//  SolarPowerView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 03/05/2024.
//

import Energy_Stats_Core
import SwiftUI

struct SolarPowerView: View {
    let value: Double?
    let solarDefinitions: SolarRangeDefinitions
    let iconScale: IconScale

    private var displayedValue: Double {
        value ?? 0
    }

    var body: some View {
        FullPageStatusView(
            iconScale: iconScale,
            icon: {
                Group {
                    SunView(solar: displayedValue, solarDefinitions: solarDefinitions, sunSize: sunSize)
                        .frame(width: iconScale.size.width, height: iconScale.size.height)
                        .if(value == nil) {
                            $0.redacted(reason: .placeholder)
                        }
                }
            },
            line1: {
                Group {
                    if let value {
                        Text(value.kW(2))
                    } else {
                        Text("xxxxx")
                            .redacted(reason: .placeholder)
                    }
                }
            },
            line2: {
                Text(" ")
            }
        )
    }

    private var sunSize: CGFloat {
        switch iconScale {
        case .small:
            16
        case .large:
            44
        }
    }
}

#Preview {
    SolarPowerView(value: 0.0, solarDefinitions: AppSettings.mock().solarDefinitions, iconScale: .large)
}
