//
//  StatsGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import SwiftUI

struct StatsGraphView: View {
    let gridImport: Double?
    let gridExport: Double?
    let home: Double?
    let batteryCharge: Double?
    let batteryDischarge: Double?
    let lastUpdated: Date

    var body: some View {
        Text("StatsGraphView")
    }
}

#Preview {
    StatsGraphView(gridImport: 1.0, gridExport: 2.0, home: 3.0, batteryCharge: 4.0, batteryDischarge: 5.0, lastUpdated: .now)
}
