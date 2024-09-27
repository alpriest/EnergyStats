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

    var body: some View {
        VStack(alignment: .center) {
            if let solar = value {
                SunView(solar: solar, solarDefinitions: solarDefinitions, sunSize: 18)
                    .frame(width: Constants.iconWidth, height: Constants.iconHeight)

                Text(solar.kW(2))
                    .multilineTextAlignment(.center)
            } else {
                SunView(solar: 0, solarDefinitions: solarDefinitions)
                    .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                    .redacted(reason: .placeholder)

                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }
}

#Preview {
    SolarPowerView(value: 0.0, solarDefinitions: AppSettings.mock().solarDefinitions)
}
