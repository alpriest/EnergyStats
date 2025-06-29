//
//  Energy_Stats_WidgetsBundle.swift
//  Energy Stats Widgets
//
//  Created by Alistair Priest on 24/09/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

@main
struct Energy_Stats_WidgetsBundle: WidgetBundle {
    var body: some Widget {
        BatteryWidget()
        TodayStatsWidget()
        TodaySolarGenerationWidget()
    }
}
