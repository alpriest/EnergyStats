//
//  ScheduleView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

enum PhaseEnabledToggleMode {
    case disabled
    case enabled(onPhaseEnabledChange: (SchedulePhase, Bool) -> Void)
    
    var isEnabled: Bool {
        switch self {
        case .disabled:
            false
        case .enabled(_):
            true
        }
    }
    
    func onChange(phase: SchedulePhase, value: Bool) {
        if case let .enabled(onPhaseEnabledChange) = self {
            onPhaseEnabledChange(phase, value)
        }
    }
}

struct ScheduleView: View {
    let schedule: Schedule
    let includePhaseDetail: Bool
    let phaseEnabledToggleMode: PhaseEnabledToggleMode

    var body: some View {
        VStack(alignment: .leading) {
            TimePeriodBarView(phases: schedule.phases)
                .padding(.bottom, 8)

            if includePhaseDetail {
                ForEach(schedule.phases) { phase in
                    SchedulePhaseListItemView(phase: phase, toggleMode: phaseEnabledToggleMode)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview {
    ScheduleView(
        schedule: Schedule.preview(),
        includePhaseDetail: true,
        phaseEnabledToggleMode: .enabled(onPhaseEnabledChange: { _, _ in })
    )
}
