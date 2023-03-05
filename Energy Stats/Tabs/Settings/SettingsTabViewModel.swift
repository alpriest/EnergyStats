//
//  SettingsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/03/2023.
//

import SwiftUI

class SettingsTabViewModel: ObservableObject {
    @Published var showColouredLines: Bool {
        didSet {
            config.showColouredLines = showColouredLines
        }
    }

    @Published var batteryCapacity: String {
        didSet {
            config.batteryCapacity = batteryCapacity
        }
    }

    @Published var showBatteryTemperature: Bool {
        didSet {
            config.showBatteryTemperature = showBatteryTemperature
        }
    }

    private var config: ConfigManaging
    private let userManager: UserManager

    init(userManager: UserManager, config: ConfigManaging) {
        self.userManager = userManager
        self.config = config
        showColouredLines = config.showColouredLines
        batteryCapacity = String(describing: config.batteryCapacity)
        showBatteryTemperature = config.showBatteryTemperature
    }

    var minSOC: Double { config.minSOC }
    var username: String { userManager.getUsername() ?? "" }

    @MainActor
    func logout() {
        userManager.logout()
    }
}
