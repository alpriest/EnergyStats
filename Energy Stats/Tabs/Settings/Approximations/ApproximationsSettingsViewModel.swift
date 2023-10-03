//
//  ApproximationsSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/10/2023.
//

import Energy_Stats_Core
import SwiftUI

class ApproximationsSettingsViewModel: ObservableObject {
    @Published var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode {
        didSet {
            configManager.selfSufficiencyEstimateMode = selfSufficiencyEstimateMode
        }
    }

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        selfSufficiencyEstimateMode = configManager.selfSufficiencyEstimateMode
    }
}
