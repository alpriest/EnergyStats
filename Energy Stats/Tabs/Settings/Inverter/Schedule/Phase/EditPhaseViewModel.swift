//
//  EditPhaseViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/11/2025.
//

import Combine
import Energy_Stats_Core
import SwiftUI

class EditPhaseViewModel: ObservableObject, ViewDataProviding {
    typealias ViewData = EditPhaseViewData

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

        if viewData.workMode == WorkMode.ForceDischarge,
           let minSoc = viewData.fields.first(where: { $0.key == "minsocongrid" })?.value,
           let fdSoc = viewData.fields.first(where: { $0.key == "fdsoc" })?.value,
           minSoc > fdSoc
        {
            fieldErrors["minsocongrid"] = "Min SoC must be less than or equal to Discharge SoC"
        }

        if viewData.startTime.toTime() >= viewData.endTime.toTime() {
            timeError = "End time must be after start time"
        } else {
            timeError = nil
        }
    }

    private func workModeChanged() {
        determineVisibleFields()
    }

    private func determineVisibleFields() {
        let mode = viewData.workMode
        let builder = FieldDefinitionBuilder(properties: configManager.scheduleProperties, phase: phase)

        var hiddenFieldKeys: Set<String> = ["maxSoc"]
        let standardField: SchedulePhaseFieldDefinition?

        switch mode {
        case .SelfUse:
            hiddenFieldKeys.insert("fdPwr")
            hiddenFieldKeys.insert("fdSoc")
            standardField = builder.make(for: "minSocOnGrid", isStandard: true, title: "Min SoC", description: nil, defaultValue: 10)
        case .Feedin:
            hiddenFieldKeys.insert("fdPwr")
            hiddenFieldKeys.insert("fdSoc")
            standardField = builder.make(for: "minSocOnGrid", isStandard: true, title: "Min SoC", description: nil, defaultValue: 10)
        case .Backup:
            hiddenFieldKeys.insert("fdPwr")
            hiddenFieldKeys.insert("fdSoc")
            standardField = builder.make(for: "minSocOnGrid", isStandard: true, title: "Min SoC", description: nil, defaultValue: 10)
        case .ForceCharge:
            standardField = builder.make(
                for: "fdSoc",
                isStandard: true,
                title: "Charge to SoC",
                description: "When the battery reaches this level, charging will stop.",
                defaultValue: 100
            )
        case .ForceDischarge:
            standardField = builder.make(
                for: "fdSoc",
                isStandard: true,
                title: "Discharge to SoC",
                description: "When the battery reaches this level, discharging will stop. If you wanted to save some battery power for later, perhaps set it to 50%.",
                defaultValue: 10
            )
        default:
            standardField = nil
        }

        let standardFields = [standardField].compactMap { $0 }
        hiddenFieldKeys.formUnion(standardFields.map { $0.key })
        hiddenFieldKeys.formUnion(configManager.scheduleProperties.compactMap { key, value in
            value.unit.isEmpty ? key : nil
        })

        let advancedFields: [SchedulePhaseFieldDefinition] = phase.extraParam
            .keys
            .filter { hiddenKey in hiddenFieldKeys.contains(where: { standardKey in standardKey.lowercased() == hiddenKey.lowercased() }) == false }
            .map { key in
                let defaultValue = defaultValue(mode: mode, key: key)
                let description = description(mode: mode, key: key)
                let label = label(mode: mode, key: key)

                return builder.make(for: key, isStandard: false, title: label, description: description, defaultValue: defaultValue)
            }

        viewData.fields = standardFields + advancedFields
        viewData.showAdvancedFields = !advancedFields.isEmpty
    }

    private func description(mode: WorkMode, key: String) -> LocalizedStringKey? {
        switch (mode, key.lowercased()) {
        case (WorkMode.ForceCharge, "fdpwr"):
            "The input power to charge your battery."
        case (WorkMode.ForceDischarge, "fdpwr"):
            "The output power level to be delivered, including your house load and grid export. E.g. If you have 5kW inverter then set this to 5000, then if the house load is 750W the other 4.25kW will be exported."
        default:
            nil
        }
    }

    private func defaultValue(mode: WorkMode, key: String) -> Double? {
        switch (mode, key.lowercased()) {
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
        switch (mode, key.lowercased()) {
        case (.ForceCharge, "fdpwr"):
            "Force Charge power"
        case (.ForceDischarge, "fdpwr"):
            "Force Discharge power"
        default:
            key
        }
    }

    func save(onSuccess: () -> Void) {
        var allFields = phase.extraParam
        let userSpecifiedFields = viewData.fields

        allFields = Dictionary(uniqueKeysWithValues: allFields.map { k, v in
            switch (viewData.workMode, k.lowercased()) {
            case (.ForceCharge, "maxsoc"):
                return (k, userSpecifiedFields.first(where: { $0.key.lowercased() == "fdsoc" })?.value ?? v)
            case (.ForceDischarge, "importlimit"):
                return (k, 0)
            case (_, "maxsoc"):
                return (k, 100)
            default:
                return (k, userSpecifiedFields.first { $0.key.lowercased() == k.lowercased() }?.value ?? v)
            }
        })

        let phase = SchedulePhaseV3(
            id: viewData.id,
            start: viewData.startTime.toTime(),
            end: viewData.endTime.toTime(),
            mode: viewData.workMode,
            extraParam: allFields
        )

        onChange(phase)
        resetDirtyState()
        onSuccess()
    }
}
