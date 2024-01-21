//
//  ScheduleDetailView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/12/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct ScheduleDetailView: View {
    let schedule: Schedule
    let onUpdate: (SchedulePhase) -> Void
    let onDelete: (String) -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading) {
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
                SchedulePhaseEditView(phase: phase,
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
        onUpdate: { _ in },
        onDelete: { _ in }
    )
}
