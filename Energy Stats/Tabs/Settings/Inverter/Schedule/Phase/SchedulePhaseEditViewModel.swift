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
        fields: [],
        showAdvancedFields: false
    ) { didSet {
        if oldValue.workMode != viewData.workMode {
            workModeChanged()
        }
        validate()
        isDirty = viewData != originalValue
    }}
    private let onChange: (SchedulePhaseV3) -> Void
    private let onDelete: (String) -> Void
    @Published var isDirty = false
    var originalValue: ViewData?
    @Published var timeError: LocalizedStringKey?
    @Published var fieldErrors: [String: LocalizedStringKey] = [:]
    private let schedule: Schedule
    private let phase: SchedulePhaseV3

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
        self.schedule = schedule
        self.phase = phase

        let viewData = ViewData(
            id: phase.id,
            startTime: Date.fromTime(phase.start),
            endTime: Date.fromTime(phase.end),
            workMode: phase.mode,
            modes: configManager.workModes.sorted(),
            fields: [],
            showAdvancedFields: false
        )
        originalValue = viewData
        self.viewData = viewData

        // Update available fields based on workmode
        determineVisibleFields()
        validate()
    }

    func binding(
        for definition: SchedulePhaseFieldDefinition,
        default defaultValue: String = ""
    ) -> Binding<String> {
        Binding(
            get: {
                if let storedValue = definition.value {
                    String(Int(storedValue))
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
        fieldErrors = [:]

        for field in viewData.fields {
            guard let value = field.value, let range = field.range else { continue }

            if value < range.min || value > range.max {
                fieldErrors[field.key] = "Please enter a number between \(Int(range.min)) and \(Int(range.max))"
            }
        }

//        if let minSOC = Int(viewData.minSOC), let fdSOC = Int(viewData.fdSOC), minSOC > fdSOC {
//            minSOCError = "Min SoC must be less than or equal to Force Discharge SoC"
//        }

        if viewData.startTime.toTime() >= viewData.endTime.toTime() {
            timeError = "End time must be after start time"
        }
    }

    private func workModeChanged() {
        determineVisibleFields()
    }

    private func determineVisibleFields() {
        let mode = viewData.workMode
        let builder = FieldDefinitionBuilder(properties: configManager.scheduleProperties, phase: phase)

        var hiddenFieldKeys: Set<String> = ["maxsoc"]
        let standardField: SchedulePhaseFieldDefinition?

        switch mode {
        case .SelfUse:
            hiddenFieldKeys.insert("fdpwr")
            hiddenFieldKeys.insert("fdsoc")
            standardField = builder.make(for: "minsocongrid", isStandard: true, title: "Min SoC", description: nil, defaultValue: 10)
        case .Feedin:
            hiddenFieldKeys.insert("fdpwr")
            hiddenFieldKeys.insert("fdsoc")
            standardField = builder.make(for: "minsocongrid", isStandard: true, title: "Min SoC", description: nil, defaultValue: 10)
        case .Backup:
            hiddenFieldKeys.insert("fdpwr")
            hiddenFieldKeys.insert("fdsoc")
            standardField = builder.make(for: "minsocongrid", isStandard: true, title: "Min SoC", description: nil, defaultValue: 10)
        case .ForceCharge:
            standardField = builder.make(
                for: "fdsoc",
                isStandard: true,
                title: "Charge to SoC",
                description: "When the battery reaches this level, charging will stop.",
                defaultValue: 100
            )
        case .ForceDischarge:
            standardField = builder.make(
                for: "fdsoc",
                isStandard: true,
                title: "Discharge to SoC",
                description: "When the battery reaches this level, discharging will stop. If you wanted to save some battery power for later, perhaps set it to 50%.",
                defaultValue: 10
            )
        default:
            standardField = nil
        }

        let standardFields = [standardField].compactMap { $0 }
        hiddenFieldKeys.formUnion(standardFields.map { $0.key.lowercased() })
        hiddenFieldKeys.formUnion(configManager.scheduleProperties.compactMap { key, value in
            value.unit.isEmpty ? key.lowercased() : nil
        })

        let advancedFields: [SchedulePhaseFieldDefinition] =
            configManager.scheduleProperties
                .keys
                .filter { allKey in hiddenFieldKeys.contains(where: { standardKey in standardKey == allKey.lowercased() }) == false }
                .map { key in
                    let defaultValue = defaultValue(mode: mode, key: key, standardFields: standardFields)
                    let description = description(mode: mode, key: key)

                    return builder.make(for: key, isStandard: false, title: key, description: description, defaultValue: defaultValue)
                }

        viewData.fields = standardFields + advancedFields
        viewData.showAdvancedFields = !advancedFields.isEmpty
    }

    private func description(mode: WorkMode, key: String) -> LocalizedStringKey? {
        switch (mode, key) {
        case (WorkMode.ForceCharge, "fdpwr"):
            "The input power to charge your battery."
        case (WorkMode.ForceDischarge, "fdpwr"):
            "The output power level to be delivered, including your house load and grid export. E.g. If you have 5kW inverter then set this to 5000, then if the house load is 750W the other 4.25kW will be exported."
        default:
            nil
        }
    }

    private func defaultValue(mode: WorkMode, key: String, standardFields: [SchedulePhaseFieldDefinition]) -> Double? {
        switch (mode, key) {
        // Force Charge
        case (_, "fdpwr"):
            if let capacity = configManager.currentDevice.value?.capacity {
                capacity * 1000.0
            } else {
                nil
            }

        case (WorkMode.ForceDischarge, "importlimit"):
            0

        default:
            nil
        }
    }

    private func label(mode: WorkMode, key: String) -> String {
        switch (mode, key) {
        case (.ForceCharge, "fdpwr"):
            "Force Charge power"
        case (.ForceDischarge, "fdpwr"):
            "Force Discharge power"
        default:
            key
        }
    }

    func save(onSuccess: () -> Void) {
        let userSpecifiedFields = viewData.fields
        let fieldsWithSensibleDefaults = userSpecifiedFields.map { field in
            switch (viewData.workMode, field.key) {
            case (.ForceCharge, "maxsoc"):
                field.copy { $0.value = userSpecifiedFields.first { $0.key == "fdsoc" }?.value }
            case (.ForceDischarge, "importlimit"):
                field.copy { $0.value = 0 }
            case (_, "maxsoc"):
                field.copy { $0.value = 100 }
            default:
                field
            }
        }

        let phase = SchedulePhaseV3(
            id: viewData.id,
            start: viewData.startTime.toTime(),
            end: viewData.endTime.toTime(),
            mode: viewData.workMode,
            extraParam: Dictionary(uniqueKeysWithValues: fieldsWithSensibleDefaults.compactMap {
                if let value = $0.value {
                    (keyAsExtraParamKey($0.key), value)
                } else {
                    nil
                }
            })
        )

        onChange(phase)
        resetDirtyState()
        onSuccess()
    }
    
    private func keyAsExtraParamKey(_ key: String) -> String {
        let fieldNames = Set(["fdSoc", "fdPwr", "maxSoc", "minSocOnGrid"])
        return fieldNames.first { $0.lowercased() == key } ?? key
    }
}
