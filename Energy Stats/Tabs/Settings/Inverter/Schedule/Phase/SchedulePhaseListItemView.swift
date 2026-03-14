//
//  SchedulePhaseListItemView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseListItemView: View {
    let phase: SchedulePhase
    private let toggleMode: PhaseEnabledToggleMode
    @State private var toggleState: Bool

    init(phase: SchedulePhase, toggleMode: PhaseEnabledToggleMode) {
        self.phase = phase
        self.toggleMode = toggleMode
        self.toggleState = phase.enabled
    }

    var body: some View {
        HStack {
            phase.displayColor
                .frame(width: 5)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading) {
                HStack {
                    (Text(phase.start.formatted(type: .start)) + Text(" - ") + Text(phase.end.formatted(type: .end))).bold()
                }

                (Text(WorkMode.title(for: phase.mode)) + Text(extra(for: phase)))
                    .foregroundStyle(Color.primary.opacity(0.5))
                    .font(.caption)

                if toggleMode.isEnabled {
                    Toggle(isOn: $toggleState, label: { Text("") })
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }.background(
            Group {
                if phase.enabled == false {
                    CrossHatchView()
                }
            }
        ).onChange(of: toggleState) {
            toggleMode.onChange(phase: phase, value: $0)
        }
    }

    private func extra(for phase: SchedulePhase) -> String {
        switch phase.mode {
        case "ForceDischarge":
            return " at \(phase.forceDischargePower)W down to \(phase.forceDischargeSOC)%"
        case "ForceCharge":
            if let maxSOC = phase.maxSOC {
                return " with \(maxSOC)% max SOC"
            } else {
                return ""
            }
        case "SelfUse":
            var result = " with \(phase.minSocOnGrid)% min SOC"

            if let maxSOC = phase.maxSOC {
                result += " and \(maxSOC)% max SOC"
            }

            return result
        case "Backup":
            if let maxSOC = phase.maxSOC {
                return " with \(maxSOC)% max SOC"
            } else {
                return ""
            }
        default:
            return ""
        }
    }
}

#Preview {
    VStack {
        SchedulePhaseListItemView(phase: Schedule.preview().phases[0], toggleMode: .disabled)
        SchedulePhaseListItemView(phase: Schedule.preview().phases[1], toggleMode: .enabled(onPhaseEnabledChange: { _, _ in }))
    }
}
