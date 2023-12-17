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
    private let allowDelete: Bool

    init(
        networking: FoxESSNetworking,
        config: ConfigManaging,
        schedule: Schedule,
        modes: [SchedulerModeResponse],
        allowDelete: Bool
    ) {
        _viewModel = StateObject(
            wrappedValue: EditScheduleViewModel(
                networking: networking,
                config: config,
                schedule: schedule,
                modes: modes
            )
        )
        self.allowDelete = allowDelete
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                ScheduleDetailView(
                    schedule: viewModel.schedule,
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

                        if allowDelete {
                            Button(role: .destructive) {
                                presentConfirmation = true
                            } label: {
                                Text("Delete schedule")
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

            BottomButtonsView(labels: BottomButtonLabels(left: "Cancel", right: "Activate"),
                              onApply: {
                                  Task {
                                      await viewModel.saveSchedule {
                                          presentationMode.wrappedValue.dismiss()
                                      }
                                  }
                              })
        }
        .navigationTitle("Edit schedule")
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
            allowDelete: true
        )
    }
}
