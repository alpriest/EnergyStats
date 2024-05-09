//
//  ScheduleTemplateListViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import Foundation

class ScheduleTemplateListViewModel: ObservableObject {
    let templateStore: TemplateStoring
    let config: ConfigManaging
    @Published var templates: [ScheduleTemplate] = []
    @Published var state: LoadState = .inactive

    init(templateStore: TemplateStoring, config: ConfigManaging) {
        self.templateStore = templateStore
        self.config = config
    }

    @MainActor
    func load() {
        templates = templateStore.load()
    }

    @MainActor
    func createTemplate(name: String) async {
        templateStore.create(named: name)
        load()
    }
}
