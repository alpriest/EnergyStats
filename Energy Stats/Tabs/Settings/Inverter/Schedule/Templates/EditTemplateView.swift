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
    @State private var newTemplateName: String = ""
    @State private var duplicateTemplateAlertIsPresented = false
    @State private var renameTemplateName: String = ""
    @State private var renameTemplateAlertIsPresented = false
    private let configManager: ConfigManaging

    init(networking: Networking, templateStore: TemplateStoring, configManager: ConfigManaging, template: ScheduleTemplate) {
        _viewModel = StateObject(
            wrappedValue: EditTemplateViewModel(
                networking: networking,
                templateStore: templateStore,
                config: configManager,
                template: template
            )
        )
        self.configManager = configManager
    }

    var body: some View {
        Form {
            OptionalView(viewModel.schedule) { schedule in
                ScheduleDetailView(
                    schedule: schedule,
                    configManager: configManager,
                    onUpdate: viewModel.updatedPhase,
                    onDelete: viewModel.deletedPhase
                )

                FooterSection {
                    VStack(alignment: .leading) {
                        HStack {
                            Button {
                                viewModel.addNewTimePeriod()
                            } label: {
                                Text("Add time period")
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                viewModel.autoFillScheduleGaps()
                            } label: {
                                Text("Autofill gaps")
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        HStack {
                            Button {
                                viewModel.activate {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } label: {
                                Image(systemName: "play")
                                    .frame(height: 24)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(schedule.phases.count == 0)

                            Button {
                                duplicateTemplateAlertIsPresented.toggle()
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .frame(height: 24)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                renameTemplateAlertIsPresented.toggle()
                            } label: {
                                Image(systemName: "pencil")
                                    .frame(height: 24)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)

                            Button(role: .destructive) {
                                presentConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .frame(height: 24)
                                    .frame(minWidth: 0, maxWidth: .infinity)
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
        .templateAlert(
            configuration: .duplicateTemplate,
            newTemplateName: $newTemplateName,
            isPresented: $duplicateTemplateAlertIsPresented
        ) {
            viewModel.duplicate(as: $0)
            presentationMode.wrappedValue.dismiss()
        }
        .templateAlert(
            configuration: .renameTemplate,
            newTemplateName: $newTemplateName,
            isPresented: $renameTemplateAlertIsPresented
        ) {
            viewModel.rename(as: $0)
            presentationMode.wrappedValue.dismiss()
        }
        .toolbarRole(.editor)
        .navigationTitle(viewModel.name ?? "Edit template")
        .loadable(viewModel.state, retry: {})
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationStack {
        EditTemplateView(
            networking: NetworkService.preview(),
            templateStore: TemplateStore.preview(),
            configManager: ConfigManager.preview(),
            template: ScheduleTemplate.preview()
        )
    }
}
