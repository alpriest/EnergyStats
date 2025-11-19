//
//  SchedulePhaseEditView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var workMode: WorkMode
    @State private var minSOC: String
    @State private var fdSOC: String
    @State private var fdPower: String
    @State private var minSOCError: LocalizedStringKey?
    @State private var fdSOCError: LocalizedStringKey?
    @State private var timeError: LocalizedStringKey?
    @State private var forceDischargePowerError: LocalizedStringKey?
    @State private var maxSOC: String
    @State private var maxSOCError: LocalizedStringKey?
    private let showMaxSOC: Bool
    private let id: String
    private let modes: [String]
    private let onChange: (SchedulePhase) -> Void
    private let onDelete: (String) -> Void

    init(
        phase: SchedulePhase,
        configManager: ConfigManaging,
        onChange: @escaping (SchedulePhase) -> Void,
        onDelete: @escaping (String) -> Void
    ) {
        self.onChange = onChange
        self.onDelete = onDelete

        self.id = phase.id
        self._startTime = State(wrappedValue: Date.fromTime(phase.start))
        self._endTime = State(wrappedValue: Date.fromTime(phase.end))
        self._workMode = State(wrappedValue: phase.mode)
        self._minSOC = State(wrappedValue: String(describing: phase.minSocOnGrid))
        self._fdSOC = State(wrappedValue: String(describing: phase.forceDischargeSOC))
        self._fdPower = State(wrappedValue: String(describing: phase.forceDischargePower))

        if let maxSOC = phase.maxSOC {
            showMaxSOC = true
            self._maxSOC = State(wrappedValue: String(describing: maxSOC))
        } else {
            showMaxSOC = false
            self.maxSOC = ""
        }

        self.modes = configManager.workModes

        validate()
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                FooterSection {
                    Text("Define your phase here. Press back to view your entire schedule.")
                }

                Section {
                    CustomDatePicker(start: $startTime, end: $endTime, includeSeconds: true)

                    Picker("Work Mode", selection: $workMode) {
                        ForEach(modes, id: \.self) { mode in
                            Text(WorkMode.title(for: mode))
                        }
                    }
                    .pickerStyle(.menu)
                } footer: {
                    VStack {
                        OptionalView(workModeDescription()) {
                            Text($0)
                                .monospacedDigit()
                        }

                        OptionalView(timeError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Min SoC")
                        NumberTextField("SoC", text: $minSOC)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(minSOCError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                        OptionalView(minSoCDescription()) {
                            Text($0)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Max SoC")
                        Spacer()
                        NumberTextField("Max SoC", text: $maxSOC)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("%")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(maxSOCError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Force Discharge SoC")
                        Spacer()
                        NumberTextField("SoC", text: $fdSOC)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("%")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(fdSOCError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                        OptionalView(forceDischargeSoCDescription()) {
                            Text($0)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Force Discharge Power")
                        Spacer()
                        NumberTextField("Power", text: $fdPower)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("W")
                    }
                } footer: {
                    VStack(alignment: .leading) {
                        OptionalView(forceDischargePowerError) {
                            Text($0)
                                .foregroundStyle(Color.red)
                        }
                        OptionalView(forceDischargePowerDescription()) {
                            Text($0)
                        }
                    }
                }

                Section {}
                    footer: {
                        Button(role: .destructive) {
                            onDelete(id)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Delete time period")
                        }.buttonStyle(.bordered)
                    }
            }

            BottomButtonsView(dirty: true) { save() }
        }
        .onChange(of: startTime) { _ in validate() }
        .onChange(of: endTime) { _ in validate() }
        .onChange(of: workMode) { _ in validate() }
        .onChange(of: minSOC) { _ in validate() }
        .onChange(of: fdSOC) { _ in validate() }
        .onChange(of: fdPower) { _ in validate() }
        .navigationTitle(.editPhase)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        if let phase = SchedulePhase(
            id: id,
            start: startTime.toTime(),
            end: endTime.toTime(),
            mode: workMode,
            minSocOnGrid: Int(minSOC) ?? 0,
            forceDischargePower: Int(fdPower) ?? 0,
            forceDischargeSOC: Int(fdSOC) ?? 0,
            maxSOC: showMaxSOC ? (Int(maxSOC) ?? 0) : nil,
            color: Color.scheduleColor(named: workMode)
        ) {
            onChange(phase)
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func minSoCDescription() -> LocalizedStringKey? {
        if case .ForceDischarge = workMode {
            return "The minimum battery state of charge. This must be at most the Force Discharge SOC value."
        }

        return nil
    }

    private func forceDischargeSoCDescription() -> LocalizedStringKey? {
        if case .ForceDischarge = workMode {
            return "When the battery reaches this level, discharging will stop. If you wanted to save some battery power for later, perhaps set it to 50%."
        }

        return nil
    }

    private func forceDischargePowerDescription() -> LocalizedStringKey? {
        if case .ForceDischarge = workMode {
            return "The output power level to be delivered, including your house load and grid export. E.g. If you have 5kW inverter then set this to 5000, then if the house load is 750W the other 4.25kW will be exported."
        }

        return nil
    }

    private func workModeDescription() -> LocalizedStringKey? {
        switch workMode {
        case WorkMode.SelfUse:
            "workmode.self_use_mode.description"
        case WorkMode.Feedin:
            "workmode.feed_in_first_mode.description"
        case WorkMode.Backup:
            "workmode.backup_mode.description"
        case WorkMode.ForceCharge:
            "workmode.force_charge_mode.description"
        case WorkMode.ForceDischarge:
            "workmode.forceDischarge.description"
        case WorkMode.PeakShaving:
            "workmode.peak_shaving.description"
        default:
            nil
        }
    }

    private func validate() {
        minSOCError = nil
        fdSOCError = nil
        timeError = nil
        forceDischargePowerError = nil

        if let minSOC = Int(minSOC), !(10...100 ~= minSOC) {
            minSOCError = "Please enter a number between 10 and 100"
        }

        if let fdSOC = Int(fdSOC), !(10...100 ~= fdSOC) {
            fdSOCError = "Please enter a number between 10 and 100"
        }

        if let minSOC = Int(minSOC), let fdSOC = Int(fdSOC), minSOC > fdSOC {
            minSOCError = "Min SoC must be less than or equal to Force Discharge SoC"
        }

        if startTime.toTime() >= endTime.toTime() {
            timeError = "End time must be after start time"
        }

        if case .ForceDischarge = workMode, Int(fdPower) == 0 {
            forceDischargePowerError = "Force Discharge power needs to be greater than 0 to discharge"
        }

        if showMaxSOC, let maxSOC = Int(maxSOC), !(10...100 ~= maxSOC) {
            maxSOCError = "Please enter a number between 10 and 100"
        }
    }
}

#Preview {
    SchedulePhaseEditView(
        phase: SchedulePhase(
            start: Time(
                hour: 19,
                minute: 30
            ),
            end: Time(
                hour: 23,
                minute: 30
            ),
            mode: "ForceDischarge",
            minSocOnGrid: 10,
            forceDischargePower: 3500,
            forceDischargeSOC: 20,
            maxSOC: 100,
            color: Color.scheduleColor(named: "ForceDischarge")
        )!,
        configManager: ConfigManager.preview(),
        onChange: { print($0.id, " changed") },
        onDelete: { print($0, " deleted") }
    )
}

struct FooterSection<V: View>: View {
    var content: () -> V

    var body: some View {
        Section {}
            footer: { content() }
    }
}
