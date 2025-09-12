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
        prepareExport()
    }

    @MainActor
    func createTemplate(name: String) async {
        templateStore.create(named: name)
        load()
    }

    var exportFile: TextFile?

    func prepareExport() {
        let wrappedTemplateList = ExportedTemplateList(
            version: 1,
            templates: templates
        )

        if let data = try? JSONEncoder().encode(wrappedTemplateList),
           let text = String(data: data, encoding: .utf8)
        {
            exportFile = TextFile(
                text: text,
                filename: "schedule_templates.json"
            )
        }
    }
    
    @MainActor
    func importTemplates(from url: URL, replaceExistingTemplates: Bool) {
        // If this URL came from a fileImporter or an external provider, it may be security-scoped
        let needsStop = url.startAccessingSecurityScopedResource()
        defer { if needsStop { url.stopAccessingSecurityScopedResource() } }

        do {
            // Read the file contents safely
            let data = try Data(contentsOf: url)

            // Decode the wrapped template list
            let importedTemplates = try JSONDecoder().decode(ExportedTemplateList.self, from: data)

            // Re-ID the templates to avoid collisions
            let remappedTemplates = importedTemplates.templates.map {
                ScheduleTemplate(
                    id: UUID().uuidString,
                    name: $0.name,
                    phases: $0.phases
                )
            }

            // Update state and persist
            if replaceExistingTemplates {
                templates = remappedTemplates
            } else {
                templates = templates + remappedTemplates
            }

            templates.forEach { templateStore.save(template: $0) }
        } catch {
            // TODO: Surface this error to the UI if desired
            print("Import error: \(error)")
        }
    }
}

struct ExportedTemplateList: Codable {
    let version: Int
    let templates: [ScheduleTemplate]
}
