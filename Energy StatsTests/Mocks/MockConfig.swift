//
//  MockConfig.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Foundation
@testable import Energy_Stats

class MockConfig: Config {
    var deviceSN: String?
    var minSOC: String?
    var batteryCapacity: String?
    var deviceID: String?
    var hasBattery: Bool = true
    var hasPV: Bool = false
    var isDemoUser: Bool = false
    var showColouredLines: Bool = true
    var showBatteryTemperature: Bool = true
    var refreshFrequency: Int = 0
    var decimalPlaces: Int = 2
    var showSunnyBackground: Bool = true
}
