//
//  SettingsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/03/2023.
//

import SwiftUI

class SettingsTabViewModel: ObservableObject {
    @Published var useColouredLines: Bool {
        didSet {
            config.useColouredLines = useColouredLines
        }
    }

    @Published var batteryCapacity: String {
        didSet {
            config.batteryCapacity = batteryCapacity
        }
    }

    private var config: ConfigManaging
    private let userManager: UserManager

    init(userManager: UserManager, config: ConfigManaging) {
        self.userManager = userManager
        self.config = config
        useColouredLines = config.useColouredLines
        batteryCapacity = String(describing: config.batteryCapacity)
    }

    var minSOC: Double { config.minSOC }
    var username: String { userManager.getUsername() ?? "" }

    @MainActor
    func logout() {
        userManager.logout()
    }
}
