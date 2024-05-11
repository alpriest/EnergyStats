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
    private var config: ScheduleTemplateConfigManager
    public init(config: ScheduleTemplateConfigManager) {
        self.config = config
    }

    public func load() -> [ScheduleTemplate] {
        config.scheduleTemplates
    }

    public func save(template: ScheduleTemplate) {
        if let index = config.scheduleTemplates.firstIndex(where: { $0.id == template.id }) {
            config.scheduleTemplates[index] = template
        } else {
            config.scheduleTemplates.append(template)
        }
    }

    public func delete(template: ScheduleTemplate) {
        config.scheduleTemplates = config.scheduleTemplates.filter { $0.id != template.id }
    }

    public func create(named name: String) {
        config.scheduleTemplates.append(ScheduleTemplate(
            id: UUID().uuidString,
            name: name,
            phases: []
        ))
    }
}

public extension TemplateStore {
    static func preview() -> TemplateStoring {
        PreviewTemplateStore()
    }
}

class PreviewTemplateStore: TemplateStoring {
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
