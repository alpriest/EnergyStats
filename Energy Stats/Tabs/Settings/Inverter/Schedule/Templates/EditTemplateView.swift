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

    init(networking: Networking, templateStore: TemplateStoring, config: ConfigManaging, template: ScheduleTemplate) {
        _viewModel = StateObject(
            wrappedValue: EditTemplateViewModel(
                networking: networking,
                templateStore: templateStore,
                config: config,
                template: template
            )
        )
    }

    var body: some View {
        Form {
            OptionalView(viewModel.schedule) { schedule in
                ScheduleDetailView(
                    schedule: schedule,
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
                            viewModel.activate {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("Activate template")
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.saveTemplate {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Text("Save")
                        }
                        .disabled(schedule.phases.count == 0)
                    }
                }
            }
        }
        .navigationTitle("Edit template")
        .loadable(viewModel.state, retry: {  })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationStack {
        EditTemplateView(
            networking: DemoNetworking(),
            templateStore: PreviewTemplateStore(),
            config: PreviewConfigManager(),
            template: ScheduleTemplate.preview()
        )
    }
}
