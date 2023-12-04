//
//  SchedulePhaseEditView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseEditView: View {
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var workMode: SchedulerModeResponse
    @State private var minSOC: String
    @State private var fdSOC: String
    @State private var fdPower: String
    private let id: String
    private let modes: [SchedulerModeResponse]
    private let onChange: (SchedulePhase) -> Void
    private let onDelete: (String) -> Void

    init(
        modes: [SchedulerModeResponse],
        phase: SchedulePhase,
        onChange: @escaping (SchedulePhase) -> Void,
        onDelete: @escaping (String) -> Void
    ) {
        self.modes = modes
        self.onChange = onChange
        self.onDelete = onDelete

        self.id = phase.id
        self._startTime = State(wrappedValue: Date.fromTime(phase.start))
        self._endTime = State(wrappedValue: Date.fromTime(phase.end))
        self._workMode = State(wrappedValue: phase.mode)
        self._minSOC = State(wrappedValue: String(describing: phase.batterySOC))
        self._fdSOC = State(wrappedValue: String(describing: phase.forceDischargeSOC))
        self._fdPower = State(wrappedValue: String(describing: phase.forceDischargePower))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    DatePicker("Start time", selection: $startTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)

                    DatePicker("End time", selection: $endTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)

                    Picker("Work mode", selection: $workMode) {
                        ForEach(modes, id: \.self) { mode in
                            Text(mode.name)
                                .tag(mode.key)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    HStack {
                        Text("Min SoC")
                        NumberTextField("Min SoC", text: $minSOC)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                } footer: {
                    OptionalView(minSoCDescription()) {
                        Text($0)
                    }
                }

                Section {
                    HStack {
                        Text("Force Discharge SoC")
                        Spacer()
                        NumberTextField("Min SoC", text: $fdSOC)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("%")
                    }
                } footer: {
                    OptionalView(forceDischargeSoCDescription()) {
                        Text($0)
                    }
                }

                Section {
                    HStack {
                        Text("Force Discharge Power")
                        Spacer()
                        NumberTextField("Min SoC", text: $fdPower)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("W")
                    }
                } footer: {
                    OptionalView(forceDischargePowerDescription()) {
                        Text($0)
                    }
                }

                Button(role: .destructive) {
                    onDelete(id)
                } label: {
                    Text("Delete phase")
                }
            }
        }
        .onChange(of: startTime) { _ in notify() }
        .onChange(of: endTime) { _ in notify() }
        .onChange(of: workMode) { _ in notify() }
        .onChange(of: minSOC) { _ in notify() }
        .onChange(of: fdSOC) { _ in notify() }
        .onChange(of: fdPower) { _ in notify() }
    }

    private func notify() {
        if let phase = SchedulePhase(
            id: id,
            start: startTime.toTime(),
            end: endTime.toTime(),
            mode: workMode,
            forceDischargePower: Int(fdPower) ?? 0,
            forceDischargeSOC: Int(fdSOC) ?? 0,
            batterySOC: Int(minSOC) ?? 0,
            color: Color.scheduleColor(named: workMode.key)
        ) {
            onChange(phase)
        }
    }

    private func minSoCDescription() -> String? {
        switch workMode.key {
        case "Backup": return nil
        case "Feedin": return nil
        case "ForceCharge": return nil
        case "ForceDischarge": return nil
        case "SelfUse": return nil
        default: return nil
        }
    }

    private func forceDischargeSoCDescription() -> String? {
        switch workMode.key {
        case "Backup": return nil
        case "Feedin": return nil
        case "ForceCharge": return nil
        case "ForceDischarge": return "The minimum battery state of charge for Force Discharge. When the battery reaches this level, discharging will stop. If you wanted to save some battery power for later, perhaps set it to 50%."
        case "SelfUse": return nil
        default: return nil
        }
    }

    private func forceDischargePowerDescription() -> String? {
        switch workMode.key {
        case "Backup": return nil
        case "Feedin": return nil
        case "ForceCharge": return nil
        case "ForceDischarge": return "The output power level to be delivered, including your house load and grid export. E.g. set this to 5000 if this is your inverter limit then if the house load is 750W the other 4.25kW will be exported"
        case "SelfUse": return nil
        default: return nil
        }
    }
}

#Preview {
    SchedulePhaseEditView(
        modes: [
            SchedulerModeResponse(color: "#8065789B", name: "Force Discharge", key: "ForceDischarge"),
            SchedulerModeResponse(color: "#80F6BD16", name: "Back Up", key: "Backup"),
            SchedulerModeResponse(color: "#805B8FF9", name: "Feed-in Priority", key: "Feedin"),
            SchedulerModeResponse(color: "#80BBE9FB", name: "Force Charge", key: "ForceCharge"),
            SchedulerModeResponse(color: "#8061DDAA", name: "Self-Use", key: "SelfUse")
        ],
        phase: SchedulePhase(
            start: Time(
                hour: 19,
                minute: 30
            ),
            end: Time(
                hour: 23,
                minute: 30
            ),
            mode: SchedulerModeResponse(color: "#ff0000", name: "Force discharge", key: "ForceDischarge"),
            forceDischargePower: 3500,
            forceDischargeSOC: 20,
            batterySOC: 20,
            color: Color.scheduleColor(named: "ForceDischarge")
        )!,
        onChange: { print($0.id, " changed") },
        onDelete: { print($0, " deleted") }
    )
}
