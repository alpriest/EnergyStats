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
    private let configManager: ConfigManaging

    init(
        networking: Networking,
        configManager: ConfigManaging,
        schedule: Schedule
    ) {
        _viewModel = StateObject(
            wrappedValue: EditScheduleViewModel(
                networking: networking,
                configManager: configManager,
                schedule: schedule
            )
        )
        self.configManager = configManager
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                ScheduleDetailView(
                    schedule: viewModel.schedule,
                    configManager: configManager,
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
                    }
                }
            }

            BottomButtonsView(labels: BottomButtonLabels(left: "Cancel", right: "Save"),
                              onApply: {
                                  Task {
                                      await viewModel.saveSchedule {
                                          presentationMode.wrappedValue.dismiss()
                                      }
                                  }
                              })
        }
        .navigationTitle(.editSchedule)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, options: .all, retry: { viewModel.unused() })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationView {
        EditScheduleView(
            networking: NetworkService.preview(),
            configManager: ConfigManager.preview(),
            schedule: Schedule.preview()
        )
    }
}
