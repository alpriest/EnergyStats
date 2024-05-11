//
//  ParameterVariableGroupEditorView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ParameterVariableGroupEditorView: View {
    @ObservedObject var viewModel: ParameterVariableGroupEditorViewModel
    @State private var presentAlert = false
    @State private var renameText = ""
    @State private var onAlertSubmission: ((String) -> Void)?
    @State private var presentConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Picker("Group", selection: $viewModel.selected) {
                        ForEach(viewModel.groups) { group in
                            Text(group.title)
                                .tag(Optional(group.id))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                } header: {
                    Text("Choose group to edit")
                } footer: {
                    HStack {
                        Button("Create") {
                            renameText = ""
                            onAlertSubmission = viewModel.create
                            presentAlert = true
                        }
                        .buttonStyle(.bordered)

                        if let selectedGroup = viewModel.selectedGroup {
                            Button("Rename") {
                                renameText = selectedGroup.title
                                onAlertSubmission = viewModel.update
                                presentAlert = true
                            }
                            .buttonStyle(.bordered)
                        }

                        Button("Delete", role: .destructive) {
                            presentConfirmation = true
                        }
                        .buttonStyle(.bordered)
                        .disabled(viewModel.groups.count == 1)
                    }
                    .alert("Group name", isPresented: $presentAlert, actions: {
                        TextField("Group name", text: $renameText)

                        Button("Apply") {
                            onAlertSubmission?(renameText)
                        }
                        Button("Cancel", role: .cancel) {
                            presentAlert = false
                        }
                    }, message: {
                        Text("Please enter the new name")
                    })
                    .confirmationDialog("Are you sure you want to delete the group '\(viewModel.selectedGroup?.title ?? "")'?",
                                        isPresented: $presentConfirmation,
                                        titleVisibility: .visible)
                    {
                        Button("Delete", role: .destructive) {
                            withAnimation {
                                viewModel.delete()
                            }
                        }

                        Button("Cancel", role: .cancel) {
                            presentConfirmation = false
                        }
                    }
                }

                Section {
                    ParameterVariableListView(variables: viewModel.variables, onTap: viewModel.toggle)
                } header: {
                    Text("Choose Parameters")
                }
            }

            BottomButtonsView {
                viewModel.apply()
            }
        }
    }
}

#Preview {
    ParameterVariableGroupEditorView(
        viewModel: ParameterVariableGroupEditorViewModel(
            configManager: ConfigManager.preview()
        )
    )
}
