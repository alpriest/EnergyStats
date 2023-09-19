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
                } header: {
                    Text("Choose group to edit")
                } footer: {
                    HStack {
                        if let selectedGroup = viewModel.selectedGroup {
                            Button("Rename...") {
                                renameText = selectedGroup.title
                                onAlertSubmission = viewModel.update
                                presentAlert = true
                            }
                            .buttonStyle(.bordered)
                        }

                        Button("Create new...") {
                            renameText = ""
                            onAlertSubmission = viewModel.create
                            presentAlert = true
                        }
                        .buttonStyle(.bordered)
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
                }

                Section {
                    ParameterVariableListView(variables: viewModel.variables, onTap: viewModel.toggle)
                } header: {
                    Text("Choose Parameters")
                }

//                Section {
//                    Button("Sort this group") {
//                        // TODO
//                    }
//
//                    Button(role: .destructive) {
//                        // TODO
//                    } label: {
//                        Text("Delete this group")
//                    }
//                }
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
            configManager: PreviewConfigManager()
        )
    )
}
