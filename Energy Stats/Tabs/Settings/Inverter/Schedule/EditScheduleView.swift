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
    @State private var presentConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    private let allowDeletion: Bool
    private let allowSaveAsActiveSchedule: Bool
    private let allowSavingTemplate: Bool

    init(
        networking: FoxESSNetworking,
        config: ConfigManaging,
        schedule: Schedule,
        modes: [SchedulerModeResponse],
        allowDeletion: Bool,
        allowSaveAsActiveSchedule: Bool,
        allowSavingTemplate: Bool
    ) {
        _viewModel = StateObject(
            wrappedValue: EditScheduleViewModel(
                networking: networking,
                config: config,
                schedule: schedule,
                modes: modes
            )
        )
        self.allowDeletion = allowDeletion
        self.allowSaveAsActiveSchedule = allowSaveAsActiveSchedule
        self.allowSavingTemplate = allowSavingTemplate
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

                        if allowSavingTemplate {
                            Button {
                                viewModel.saveTemplate()
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Save template")
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.schedule.phases.count == 0)
                        }

                        if allowSaveAsActiveSchedule {
                            Button {
                                viewModel.saveSchedule()
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Activate schedule")
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.schedule.phases.count == 0)
                        }

                        if allowDeletion {
                            Button(role: .destructive) {
                                presentConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete this schedule")
                                }
                            }
                            .buttonStyle(.bordered)
                            .padding(.vertical, 4)
                            .confirmationDialog("Are you sure you want to delete this schedule?",
                                                isPresented: $presentConfirmation,
                                                titleVisibility: .visible)
                            {
                                Button("Delete", role: .destructive) {
                                    viewModel.deleteSchedule {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }

                                Button("Cancel", role: .cancel) {
                                    presentConfirmation = false
                                }
                            }
                        }
                    }
                }
        }
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationView {
        EditScheduleView(
            networking: DemoNetworking(),
            config: PreviewConfigManager(),
            schedule: Schedule.preview(),
            modes: SchedulerModeResponse.preview(),
            allowDeletion: true,
            allowSaveAsActiveSchedule: true,
            allowSavingTemplate: true
        )
    }
}
