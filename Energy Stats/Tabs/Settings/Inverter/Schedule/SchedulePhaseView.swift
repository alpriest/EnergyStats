//
//  SchedulePhaseView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/11/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseView: View {
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var workMode: SchedulerModeResponse
    @State private var minSOC: String
    @State private var fdSOC: String
    @State private var fdPower: String
    private let modes: [SchedulerModeResponse]

    init(modes: [SchedulerModeResponse], phase: SchedulePhase?) {
        self.modes = modes

        if let phase {
            self._startTime = State(wrappedValue: Date.fromTime(phase.start))
            self._endTime = State(wrappedValue: Date.fromTime(phase.end))
            self._workMode = State(wrappedValue: phase.mode)
            self._minSOC = State(wrappedValue: String(describing: phase.batterySOC))
            self._fdSOC = State(wrappedValue: String(describing: phase.forceDischargeSOC))
            self._fdPower = State(wrappedValue: String(describing: phase.forceDischargePower))
        } else {
            self._startTime = State(wrappedValue: Date())
            self._endTime = State(wrappedValue: Date())
            self._workMode = State(wrappedValue: modes.first!)
            self._minSOC = State(wrappedValue: "10")
            self._fdSOC = State(wrappedValue: "10")
            self._fdPower = State(wrappedValue: "0")
        }
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
            }
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
    SchedulePhaseView(
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
            color: .linesPositive
        )
    )
}
