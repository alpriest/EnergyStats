//
//  ScheduleTemplateListViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation

class ScheduleTemplateListViewModel: ObservableObject {
    let networking: FoxESSNetworking
    let config: ConfigManaging
    @Published var templates: [ScheduleTemplate] = []
    @Published var state: LoadState = .inactive
    @Published var schedule: Schedule?

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config
    }

    @MainActor
    func load() async {
        do {
            let templatesResponse = try await networking.fetchScheduleTemplates()
            self.templates = templatesResponse.data.compactMap { $0.toScheduleTemplate() }
        } catch {
            state = LoadState.error(error, error.localizedDescription)
        }
    }

    func loadTemplate(id: String?) {
        guard let id else {
            schedule = nil
            return
        }

        // Load from network
    }

    @MainActor
    func createTemplate(name: String, description: String) async {
        guard state == .inactive else { return }

        self.state = .active(String(key: .saving))

        do {
            try await self.networking.createScheduleTemplate(name: name, description: description)
            await self.load()
        } catch {
            self.state = LoadState.error(error, error.localizedDescription)
        }
    }
}
