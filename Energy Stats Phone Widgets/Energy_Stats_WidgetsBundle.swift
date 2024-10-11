//
//  Energy_Stats_WidgetsBundle.swift
//  Energy Stats Widgets
//
//  Created by Alistair Priest on 24/09/2023.
//

import WidgetKit
import SwiftUI

@main
struct Energy_Stats_WidgetsBundle: WidgetBundle {
    var body: some Widget {
        BatteryWidget()
        TodayStatsWidget()
    }
}
