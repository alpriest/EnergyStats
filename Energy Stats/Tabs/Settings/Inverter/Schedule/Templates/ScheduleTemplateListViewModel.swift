//
//  ScheduleTemplateListViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation

class ScheduleTemplateListViewModel: ObservableObject {
    let networking: Networking
    let config: ConfigManaging
    @Published var templates: [ScheduleTemplateSummary] = []
    @Published var state: LoadState = .inactive

    init(networking: Networking, config: ConfigManaging) {
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

    @MainActor
    func createTemplate(name: String, description: String) async {
        guard state == .inactive else { return }

        state = .active("Saving")

        do {
            try await self.networking.createScheduleTemplate(name: name, description: description)
            await self.load()
        } catch {
            self.state = LoadState.error(error, error.localizedDescription)
        }
    }
}
