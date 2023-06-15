//
//  MyWidgetBundle.swift
//  Widget
//
//  Created by Alistair Priest on 14/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

@main
struct MyWidgetBundle: WidgetBundle {
    var body: some Widget {
        PowerFlowValuesWidget()
        BatteryWidget()
    }
}
