//
//  ScheduleDetailView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleDetailView: View {
    let schedule: Schedule
    let modes: [SchedulerModeResponse]
    let onUpdate: (SchedulePhase) -> Void
    let onDelete: (String) -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                if !schedule.name.isEmpty {
                    Text(schedule.name)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                }

                TimePeriodBarView(phases: schedule.phases)
                    .padding(.bottom, 22)
            }
        }

        if schedule.phases.count == 0 {
            FooterSection {
                Text("You have no time periods defined. Add a time period to define how you'd like your inverter to behave during specific hours.")
            }
        }

        ForEach(schedule.phases) { phase in
            NavigationLink {
                SchedulePhaseEditView(modes: modes,
                                      phase: phase,
                                      onChange: onUpdate,
                                      onDelete: onDelete)
            } label: {
                SchedulePhaseListItemView(phase: phase)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScheduleDetailView(
        schedule: Schedule.preview(),
        modes: SchedulerModeResponse.preview(),
        onUpdate: { _ in },
        onDelete: { _ in }
    )
}
