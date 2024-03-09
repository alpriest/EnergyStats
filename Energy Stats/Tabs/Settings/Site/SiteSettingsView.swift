//
//  PowerStationSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/03/2024.
//

import SwiftUI
import Energy_Stats_Core

struct PowerStationSettingsView: View {
    let station: PowerStationDetail

    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    PowerStationSettingsView(station: PowerStationDetail(stationName: "station 1", capacity: 5700.0, timezone: "Europe/London"))
}
