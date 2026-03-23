//
//  SchedulePhaseListItemView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseListItemView: View {
    private let phase: SchedulePhaseV3

    init(phase: SchedulePhaseV3) {
        self.phase = phase
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
    }

    private func extra(for phase: SchedulePhaseV3) -> String {
        switch phase.mode {
        case WorkMode.ForceDischarge:
            return " at \(phase.forceDischargePower)W down to \(phase.forceDischargeSoc)%"
        case WorkMode.ForceCharge:
            return " at \(phase.forceDischargePower)W up to \(phase.forceDischargeSoc)%"
        case WorkMode.SelfUse:
            return " \(phase.minSocOnGrid)% min SOC"
        case WorkMode.Backup:
            return ""
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

extension SchedulePhaseV3 {
    var forceDischargePower: String {
        stringValueFor(key: "fdPwr")
    }

    var forceDischargeSoc: String {
        stringValueFor(key: "fdSoc")
    }

    var minSocOnGrid: String {
        stringValueFor(key: "minSocOnGrid")
    }
}
