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

    var body: some View {
        HStack {
            phase.color
                .frame(width: 5)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 4)

            VStack(alignment: .leading) {
                (Text(phase.start.formatted(type: .start)) + Text(" - ") + Text(phase.end.formatted(type: .end))).bold()

                (Text(phase.mode.title) + Text(extra(for: phase)))
                    .foregroundStyle(Color.primary.opacity(0.5))
                    .font(.caption)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func extra(for phase: SchedulePhase) -> String {
        switch phase.mode {
        case .ForceDischarge:
            return " at \(phase.forceDischargePower)W down to \(phase.forceDischargeSOC)%"
        case .ForceCharge:
            if let maxSOC = phase.maxSOC {
                return " with max SOC \(maxSOC)%"
            } else {
                return ""
            }
        case .SelfUse:
            var result = " with \(phase.minSocOnGrid)% min SOC"

            if let maxSOC = phase.maxSOC {
                result += " and max SOC \(maxSOC)%"
            }

            return result
        case .Backup:
            if let maxSOC = phase.maxSOC {
                return " with max SOC \(maxSOC)%"
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
        SchedulePhaseListItemView(phase: Schedule.preview().phases[0])
        SchedulePhaseListItemView(phase: Schedule.preview().phases[1])
    }
}
