//
//  SchedulePhaseEditViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/11/2025.
//

import Combine
import Energy_Stats_Core
import SwiftUI

class SchedulePhaseEditViewModel: ObservableObject, ViewDataProviding {
    typealias ViewData = SchedulePhaseEditViewData

    private let configManager: ConfigManaging
    @Published var viewData = ViewData(
        id: "",
        startTime: .now,
        endTime: .now,
        workMode: .Feedin,
        modes: [],
        fields: []
    ) { didSet {
        validate()
        isDirty = viewData != originalValue
    }}
    private let onChange: (SchedulePhaseV3) -> Void
    private let onDelete: (String) -> Void
    @Published var isDirty = false
    var originalValue: ViewData?
    @Published var minSOCError: LocalizedStringKey?
    @Published var fdSOCError: LocalizedStringKey?
    @Published var timeError: LocalizedStringKey?
    @Published var forceDischargePowerError: LocalizedStringKey?
    @Published var maxSOCError: LocalizedStringKey?

    init(
        configManager: ConfigManaging,
        schedule: Schedule,
        phase: SchedulePhaseV3,
        onChange: @escaping (SchedulePhaseV3) -> Void,
        onDelete: @escaping (String) -> Void
    ) {
        self.configManager = configManager
        self.onChange = onChange
        self.onDelete = onDelete

        let standardFields: [SchedulePhaseFieldDefinition] = switch phase.mode {
        case .SelfUse:
            [
                schedule.buildFieldDefinition(for: "minSoc", properties: configManager.scheduleProperties, isStandard: true, title: "Min SoC", phase: phase)
            ]
        case .Feedin:
            [
                schedule.buildFieldDefinition(for: "minSoc", properties: configManager.scheduleProperties, isStandard: true, title: "Min SoC", phase: phase)
            ]
        case .Backup:
            [
                schedule.buildFieldDefinition(for: "minSoc", properties: configManager.scheduleProperties, isStandard: true, title: "Min SoC", phase: phase)
            ]
        case .ForceCharge:
            [
                schedule.buildFieldDefinition(for: "fdSoc", properties: configManager.scheduleProperties, isStandard: true, title: "Min SoC", phase: phase)
            ]
        case .ForceDischarge:
            [
                schedule.buildFieldDefinition(for: "fdSoc", properties: configManager.scheduleProperties, isStandard: true, title: "Min SoC", phase: phase)
            ]
        default:
            []
        }

        var advancedFields: [SchedulePhaseFieldDefinition] =
            phase.extraParam
                .keys
                .filter { allKey in standardFields.contains(where: { standardKey in standardKey.key == allKey }) == false }
                .map { key in
                    schedule.buildFieldDefinition(for: key, properties: configManager.scheduleProperties, isStandard: false, title: key, phase: phase)
                }

        let viewData = ViewData(
            id: phase.id,
            startTime: Date.fromTime(phase.start),
            endTime: Date.fromTime(phase.end),
            workMode: phase.mode,
            modes: configManager.workModes.sorted(),
            fields: standardFields + advancedFields
        )
        originalValue = viewData
        self.viewData = viewData

        validate()
    }

    func binding(
        for definition: SchedulePhaseFieldDefinition,
        default defaultValue: String = ""
    ) -> Binding<String> {
        Binding(
            get: {
                if let storedValue = definition.value {
                    String(storedValue)
                } else {
                    defaultValue
                }
            },
            set: { newValue in
                var copy = self.viewData
                copy.fields = copy.fields.map {
                    $0.key == definition.key ? $0.copy { $0.value = Double(newValue) } : $0
                }
                self.viewData = copy
            }
        )
    }

    private func validate() {
        // TODO: Errors
//        var minSOCError: LocalizedStringKey? = nil
//        var fdSOCError: LocalizedStringKey? = nil
//        var timeError: LocalizedStringKey? = nil
//        var forceDischargePowerError: LocalizedStringKey? = nil
//        var maxSOCError: LocalizedStringKey? = nil
//
//        if let minSOC = Int(viewData.minSOC), !(10...100 ~= minSOC) {
//            minSOCError = "Please enter a number between 10 and 100"
//        }
//
//        if let fdSOC = Int(viewData.fdSOC), !(10...100 ~= fdSOC) {
//            fdSOCError = "Please enter a number between 10 and 100"
//        }
//
//        if let minSOC = Int(viewData.minSOC), let fdSOC = Int(viewData.fdSOC), minSOC > fdSOC {
//            minSOCError = "Min SoC must be less than or equal to Force Discharge SoC"
//        }
//
//        if viewData.startTime.toTime() >= viewData.endTime.toTime() {
//            timeError = "End time must be after start time"
//        }
//
//        if case .ForceDischarge = viewData.workMode, Int(viewData.fdPower) == 0 {
//            forceDischargePowerError = "Force Discharge power needs to be greater than 0 to discharge"
//        }
//
//        if viewData.showMaxSOC, let maxSOC = Int(viewData.maxSOC), !(10...100 ~= maxSOC) {
//            maxSOCError = "Please enter a number between 10 and 100"
//        }
//
//        self.minSOCError = minSOCError
//        self.fdSOCError = fdSOCError
//        self.timeError = timeError
//        self.forceDischargePowerError = forceDischargePowerError
//        self.maxSOCError = maxSOCError
    }

    func save(onSuccess: () -> Void) {
        let phase = SchedulePhaseV3(
            id: viewData.id,
            enabled: true,
            start: viewData.startTime.toTime(),
            end: viewData.endTime.toTime(),
            mode: viewData.workMode,
            extraParam: Dictionary(uniqueKeysWithValues: viewData.fields.compactMap {
                if let value = $0.value {
                    ($0.key, value)
                } else {
                    nil
                }
            })
        )

        onChange(phase)
        resetDirtyState()
        onSuccess()
    }
}
