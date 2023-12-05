//
//  EditTemplateViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/12/2023.
//

import Energy_Stats_Core
import Foundation

class EditTemplateViewModel: ObservableObject {
    @Published var state: LoadState = .inactive
    @Published var schedule: Schedule?
    private let networking: FoxESSNetworking
    private let config: ConfigManaging
    private let modes: [SchedulerModeResponse]
    private let templateID: String

    init(networking: FoxESSNetworking, config: ConfigManaging, templateID: String, modes: [SchedulerModeResponse]) {
        self.networking = networking
        self.config = config
        self.modes = modes
        self.templateID = templateID
    }
}
