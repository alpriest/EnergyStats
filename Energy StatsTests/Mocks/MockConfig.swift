//
//  MockConfig.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Foundation
@testable import Energy_Stats
import Energy_Stats_Core

class MockConfig: Config {
    var showInW: Bool = false
    var isDemoUser: Bool = false
    var showColouredLines: Bool = true
    var showBatteryTemperature: Bool = true
    var refreshFrequency: Int = 0
    var decimalPlaces: Int = 2
    var showSunnyBackground: Bool = true
    var showUsableBatteryOnly: Bool = false
    var showBatteryEstimate: Bool = false
    var devices: Data? = nil
    var selectedDeviceID: String? = nil
}
