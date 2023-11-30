//
//  ScheduleViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import Foundation

class ScheduleViewModel: ObservableObject {
    let networking: FoxESSNetworking
    let config: ConfigManaging
    @Published var schedule: Schedule?
    @Published var state: LoadState = .inactive
    @Published var alertContent: AlertContent?

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
    }

    @MainActor
    func load() {
        schedule = .preview()
    }

    func save() {}
}
