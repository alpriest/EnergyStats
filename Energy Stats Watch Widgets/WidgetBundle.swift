//
//  WidgetBundle.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 28/04/2024.
//

import WidgetKit
import SwiftUI

@main
struct WatchWidgetsBundle: WidgetBundle {
    var body: some Widget {
        BatteryStatusWidget()
        CircularBatteryStatusWidget()
        CornerBatteryStatusWidget()
        RectangularBatteryStatusWidget()
    }
}
