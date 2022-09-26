//
//  MockConfig.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

import Foundation
@testable import Energy_Stats

class MockConfig: Config {
    var minSOC: String?
    var batteryCapacity: String?
    var deviceID: String?
    var hasBattery: Bool = false
    var hasPV: Bool = false
}
