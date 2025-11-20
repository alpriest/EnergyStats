//
//  SchedulePhaseEditViewModel.swift
//
//
//  Created by Alistair Priest on 20/11/2025.
//

import Combine
import Energy_Stats_Core
import SwiftUI

class SchedulePhaseEditViewModel: ObservableObject {
    private let configManager: ConfigManaging
    @Published var viewData = SchedulePhaseEditViewData(
        id: "",
        startTime: .now,
        endTime: .now,
        workMode: .Feedin,
        minSOC: "",
        fdSOC: "",
        fdPower: "",
        maxSOC: "",
        showMaxSOC: false,
        modes: []
    ) { didSet {
        validate()
        isDirty = viewData != originalValue
    }}
    private let onChange: (SchedulePhase) -> Void
    private let onDelete: (String) -> Void
    @Published var isDirty = false
    private let originalValue: SchedulePhaseEditViewData?

    init(
        configManager: ConfigManaging,
        phase: SchedulePhase,
        onChange: @escaping (SchedulePhase) -> Void,
        onDelete: @escaping (String) -> Void
    ) {
        self.configManager = configManager
        self.onChange = onChange
        self.onDelete = onDelete

        let maxSOC: String
        let showMaxSOC: Bool

        if let phaseMaxSOC = phase.maxSOC {
            showMaxSOC = true
            maxSOC = String(phaseMaxSOC)
        } else {
            showMaxSOC = false
            maxSOC = ""
        }

        let viewData = SchedulePhaseEditViewData(
            id: phase.id,
            startTime: Date.fromTime(phase.start),
            endTime: Date.fromTime(phase.end),
            workMode: phase.mode,
            minSOC: String(phase.minSocOnGrid),
            fdSOC: String(phase.forceDischargeSOC),
            fdPower: String(phase.forceDischargePower),
            maxSOC: maxSOC,
            showMaxSOC: showMaxSOC,
            modes: configManager.workModes
        )
        originalValue = viewData
        self.viewData = viewData

        validate()
    }

    private func validate() {
        var minSOCError: LocalizedStringKey? = nil
        var fdSOCError: LocalizedStringKey? = nil
        var timeError: LocalizedStringKey? = nil
        var forceDischargePowerError: LocalizedStringKey? = nil
        var maxSOCError: LocalizedStringKey? = nil

        if let minSOC = Int(viewData.minSOC), !(10...100 ~= minSOC) {
            minSOCError = "Please enter a number between 10 and 100"
        }

        if let fdSOC = Int(viewData.fdSOC), !(10...100 ~= fdSOC) {
            fdSOCError = "Please enter a number between 10 and 100"
        }

        if let minSOC = Int(viewData.minSOC), let fdSOC = Int(viewData.fdSOC), minSOC > fdSOC {
            minSOCError = "Min SoC must be less than or equal to Force Discharge SoC"
        }

        if viewData.startTime.toTime() >= viewData.endTime.toTime() {
            timeError = "End time must be after start time"
        }

        if case .ForceDischarge = viewData.workMode, Int(viewData.fdPower) == 0 {
            forceDischargePowerError = "Force Discharge power needs to be greater than 0 to discharge"
        }

        if viewData.showMaxSOC, let maxSOC = Int(viewData.maxSOC), !(10...100 ~= maxSOC) {
            maxSOCError = "Please enter a number between 10 and 100"
        }

        viewData = viewData.copy {
            $0.minSOCError = minSOCError
            $0.fdSOCError = fdSOCError
            $0.timeError = timeError
            $0.forceDischargePowerError = forceDischargePowerError
            $0.maxSOCError = maxSOCError
        }
    }

    func save(onSuccess: () -> Void) {
        if let phase = SchedulePhase(
            id: viewData.id,
            start: viewData.startTime.toTime(),
            end: viewData.endTime.toTime(),
            mode: viewData.workMode,
            minSocOnGrid: Int(viewData.minSOC) ?? 0,
            forceDischargePower: Int(viewData.fdPower) ?? 0,
            forceDischargeSOC: Int(viewData.fdSOC) ?? 0,
            maxSOC: viewData.showMaxSOC ? (Int(viewData.maxSOC) ?? 0) : nil,
            color: Color.scheduleColor(named: viewData.workMode)
        ) {
            onChange(phase)
            onSuccess()
        }
    }
}
