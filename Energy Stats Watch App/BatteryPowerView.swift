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

    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 36))
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(battery == nil ? .iconDisabled : battery.tintColor)

            if let batterySOC, let battery {
                Text(abs(battery).kW(2))
                Text(batterySOC, format: .percent)
            } else {
                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: nil)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: 0)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: -0.5)
}

#Preview {
    BatteryPowerView(batterySOC: 0.22, battery: 0.5)
}
