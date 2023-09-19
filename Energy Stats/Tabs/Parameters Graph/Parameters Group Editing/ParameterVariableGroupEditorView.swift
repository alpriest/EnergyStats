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
    @State private var presentRenameAlert = false
    @State private var renameText = ""

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
                                presentRenameAlert = true
                            }
                            .buttonStyle(.bordered)
                            .alert("Login", isPresented: $presentRenameAlert, actions: {
                                TextField("Username", text: $renameText)

                                Button("OK", action: {
                                    viewModel.update(title: renameText)
                                })
                                Button("Cancel", role: .cancel, action: {
                                    presentRenameAlert = false
                                })
                            }, message: {
                                Text("Please enter your username and password.")
                            })
                        }

                        Button("Create new...") {
                            // TODO:
                        }.buttonStyle(.bordered)
                    }
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
