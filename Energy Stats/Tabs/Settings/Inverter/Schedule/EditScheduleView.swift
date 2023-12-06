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
                FooterSection {
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

            FooterSection {
                VStack(alignment: .leading) {
                    Button {
                        viewModel.addNewTimePeriod()
                    } label: {
                        Text("Add time period")
                    }.buttonStyle(.borderedProminent)

                    if allowSavingTemplate {
                        Button {
                            viewModel.saveTemplate {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("Save template")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.schedule.phases.count == 0)
                    }

                    if allowSaveAsActiveSchedule {
                        Button {
                            Task {
                                await viewModel.saveSchedule {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } label: {
                            Text("Activate schedule")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.schedule.phases.count == 0)
                    }

                    if allowDeletion {
                        Button(role: .destructive) {
                            presentConfirmation = true
                        } label: {
                            Text("Delete this schedule")
                        }
                        .buttonStyle(.bordered)
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
        .navigationTitle("Edit Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .loadable($viewModel.state, allowRetry: false, retry: { viewModel.unused() })
        .alert(alertContent: $viewModel.alertContent)
    }
}

struct FooterSection<V: View>: View {
    var content: () -> V

    var body: some View {
        Section {}
            footer: { content() }
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
