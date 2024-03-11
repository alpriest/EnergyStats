//
//  PowerStationSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/03/2024.
//

import Energy_Stats_Core
import SwiftUI

struct PowerStationSettingsView: View {
    let station: PowerStationDetail

    var body: some View {
        Form {
            Section {
                ESLabeledText("Name", value: station.stationName)

                ESLabeledText("Capacity", value: station.capacity.w())

                ESLabeledText("Timezone", value: station.timezone)
            }
        }
        .navigationTitle("Power station")
    }
}

#Preview {
    NavigationView {
        PowerStationSettingsView(station: PowerStationDetail(stationName: "station 1", capacity: 5700.0, timezone: "Europe/London"))
    }
}
