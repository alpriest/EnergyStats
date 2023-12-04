//
//  ScheduleView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleView: View {
    let schedule: Schedule
    let modes: [SchedulerModeResponse]

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text(schedule.name)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)

                TimePeriodBarView(phases: schedule.phases)
                    .padding(.bottom, 22)
            }
        }

        if schedule.phases.count == 0 {
            Section {}
                    footer: {
                    Text("You have no time periods defined.")
                }
        }

        ForEach(schedule.phases) { phase in
            NavigationLink {
                SchedulePhaseEditView(modes: modes,
                                      phase: phase,
                                      onChange: { _ in
//                                              viewModel.updated(phase: $0)
                                      },
                                      onDelete: { _ in
//                                              viewModel.deleted(id: $0)
                                      })
            } label: {
                HStack {
                    phase.color
                        .frame(width: 5)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)

                    VStack(alignment: .leading) {
                        (Text(phase.start.formatted) + Text(" - ") + Text(phase.end.formatted)).bold()

                        Text(phase.mode.name)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)

//            Button {
//                viewModel.addNewTimePeriod()
//            } label: {
//                Text("Add new time period")
//            }
    }
}

#Preview {
    Form {
        ScheduleView(
            schedule: Schedule(name: nil, phases: []),
            modes: []
        )
    }
}
