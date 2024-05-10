//
//  TemplateStore.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 09/05/2024.
//

import Foundation

public protocol TemplateStoring {
    func load() -> [ScheduleTemplate]
    func save(template: ScheduleTemplate)
    func delete(template: ScheduleTemplate)
    func create(named name: String)
}

public class TemplateStore: TemplateStoring {
    private let defaultsKey = "scheduleTemplates"
    private var store: [ScheduleTemplate] {
        get {
            guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return [] }
            let templates = (try? JSONDecoder().decode([ScheduleTemplate].self, from: data)) ?? []
            return templates
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    public init() {}

    public func load() -> [ScheduleTemplate] {
        store
    }

    public func save(template: ScheduleTemplate) {
        if let index = store.firstIndex(where: { $0.id == template.id }) {
            store[index] = template
        } else {
            store.append(template)
        }
    }

    public func delete(template: ScheduleTemplate) {
        store = store.filter { $0.id != template.id }
    }

    public func create(named name: String) {
        store.append(ScheduleTemplate(
            id: UUID().uuidString,
            name: name,
            phases: []
        ))
    }
}

public class PreviewTemplateStore: TemplateStoring {
    public init() {}
    public func load() -> [ScheduleTemplate] {
        [
            ScheduleTemplate(id: "1", name: "Force discharge", phases: [
                SchedulePhase(
                    start: Time(
                        hour: 1,
                        minute: 00
                    ),
                    end: Time(
                        hour: 2,
                        minute: 00
                    ),
                    mode: .ForceCharge,
                    minSocOnGrid: 100,
                    forceDischargePower: 0,
                    forceDischargeSOC: 100,
                    color: .linesNegative
                )!,
                SchedulePhase(
                    start: Time(
                        hour: 10,
                        minute: 30
                    ),
                    end: Time(
                        hour: 14,
                        minute: 30
                    ),
                    mode: .ForceDischarge,
                    minSocOnGrid: 20,
                    forceDischargePower: 3500,
                    forceDischargeSOC: 20,
                    color: .linesPositive
                )!,
            ]),
            ScheduleTemplate(id: "2", name: "Force charge overnight", phases: [
                SchedulePhase(
                    start: Time(
                        hour: 1,
                        minute: 00
                    ),
                    end: Time(
                        hour: 2,
                        minute: 00
                    ),
                    mode: .ForceCharge,
                    minSocOnGrid: 100,
                    forceDischargePower: 0,
                    forceDischargeSOC: 100,
                    color: .linesNegative
                )!,
                SchedulePhase(
                    start: Time(
                        hour: 10,
                        minute: 30
                    ),
                    end: Time(
                        hour: 14,
                        minute: 30
                    ),
                    mode: .ForceDischarge,
                    minSocOnGrid: 20,
                    forceDischargePower: 3500,
                    forceDischargeSOC: 20,
                    color: .linesPositive
                )!,
            ]),
        ]
    }

    public func save(template: ScheduleTemplate) {}

    public func delete(template: ScheduleTemplate) {}

    public func create(named name: String) {}
}
