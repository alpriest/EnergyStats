//
//  EditScheduleView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct EditScheduleView: View {
    @StateObject private var viewModel: EditScheduleViewModel

    init(networking: FoxESSNetworking, config: ConfigManaging, schedule: Schedule, modes: [SchedulerModeResponse]) {
        _viewModel = StateObject(
            wrappedValue: EditScheduleViewModel(
                networking: networking,
                config: config,
                schedule: schedule,
                modes: modes
            )
        )
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    if !viewModel.schedule.name.isEmpty {
                        Text(viewModel.schedule.name)
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom)
                    }

                    TimePeriodBarView(phases: viewModel.schedule.phases)
                        .padding(.bottom, 22)
                }
            }

            if viewModel.schedule.phases.count == 0 {
                Section {}
                    footer: {
                        Text("You have no time periods defined. Add a time period to define how you'd like your inverter to behave during specific hours.")
                    }
            }

            ForEach(viewModel.schedule.phases) { phase in
                NavigationLink {
                    SchedulePhaseEditView(modes: viewModel.modes,
                                          phase: phase,
                                          onChange: {
                                              viewModel.updated(phase: $0)
                                          },
                                          onDelete: {
                                              viewModel.deleted(phase: $0)
                                          })
                } label: {
                    SchedulePhaseListItemView(phase: phase)
                }
            }
            .frame(maxWidth: .infinity)

            Section {}
            footer: {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.addNewTimePeriod()
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add time period")
                            }
                        }.buttonStyle(.bordered)

                        Button {
                            viewModel.applyCurrentSchedule()
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Save and activate schedule")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.schedule.phases.count == 0)
                    }
                }
        }
    }
}

#Preview {
    NavigationView {
        EditScheduleView(
            networking: DemoNetworking(),
            config: PreviewConfigManager(),
            schedule: Schedule.preview(),
            modes: SchedulerModeResponse.preview()
        )
    }
}
