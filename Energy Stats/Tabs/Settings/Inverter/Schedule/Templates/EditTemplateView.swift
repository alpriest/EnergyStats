//
//  EditTemplateView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct EditTemplateView: View {
    @StateObject private var viewModel: EditTemplateViewModel
    @State private var presentConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    init(networking: FoxESSNetworking, config: ConfigManaging, templateID: String, modes: [SchedulerModeResponse]) {
        _viewModel = StateObject(
            wrappedValue: EditTemplateViewModel(
                networking: networking,
                config: config,
                templateID: templateID,
                modes: modes
            )
        )
    }

    var body: some View {
        Form {
            OptionalView(viewModel.schedule) { schedule in
                ScheduleDetailView(
                    schedule: schedule,
                    modes: viewModel.modes,
                    onUpdate: viewModel.updatedPhase,
                    onDelete: viewModel.deletedPhase
                )

                FooterSection {
                    VStack(alignment: .leading) {
                        Button {
                            viewModel.addNewTimePeriod()
                        } label: {
                            Text("Add time period")
                        }.buttonStyle(.borderedProminent)

                        Button {
                            viewModel.autoFillScheduleGaps()
                        } label: {
                            Text("Autofill gaps")
                        }.buttonStyle(.borderedProminent)

                        Button {
                            viewModel.saveTemplate {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("Save template")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(schedule.phases.count == 0)

                        Button(role: .destructive) {
                            presentConfirmation = true
                        } label: {
                            Text("Delete template")
                        }
                        .buttonStyle(.bordered)
                        .confirmationDialog("Are you sure you want to delete this template?",
                                            isPresented: $presentConfirmation,
                                            titleVisibility: .visible)
                        {
                            Button("Delete", role: .destructive) {
                                viewModel.deleteTemplate {
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
        .navigationTitle("Edit template")
        .navigationBarTitleDisplayMode(.inline)
        .loadable($viewModel.state, retry: { Task { await viewModel.load() } })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    EditTemplateView(
        networking: DemoNetworking(),
        config: PreviewConfigManager(),
        templateID: "abc",
        modes: SchedulerModeResponse.preview()
    )
}
