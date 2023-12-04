//
//  ScheduleView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleView: View {
    @StateObject private var viewModel: ScheduleViewModel

    init(schedule: Schedule, modes: [SchedulerModeResponse]) {
        _viewModel = StateObject(wrappedValue: ScheduleViewModel(schedule: schedule, modes: modes))
    }

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text(viewModel.schedule.name)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)

                TimePeriodBarView(phases: viewModel.schedule.phases)
                    .padding(.bottom, 22)
            }
        }

        if viewModel.schedule.phases.count == 0 {
            Section {}
                    footer: {
                    Text("You have no time periods defined.")
                }
        }

        ForEach(viewModel.schedule.phases) { phase in
            NavigationLink {
                SchedulePhaseEditView(modes: viewModel.modes,
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

        Button {
            viewModel.appendPhasesInGaps(mode: SchedulerModeResponse(color: "", name: "Self Use", key: "SelfUse"), soc: 20)
        } label: {
            Text("Autofill gaps")
        }
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
