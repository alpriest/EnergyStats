//
//  ParameterGraphHeaderView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ParameterGraphHeaderView: View {
    @StateObject var viewModel: ParameterGraphHeaderViewModel
    @Binding var showingVariables: Bool

    var body: some View {
        HStack {
            Menu {
                Button {
                    showingVariables.toggle()
                } label: {
                    Text("Parameters...")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("accessibility.menu")
                .accessibilityIdentifier("variable_chooser")

                Divider()

                Button {
                    viewModel.hours = 6
                } label: {
                    Label("6 hours", systemImage: viewModel.hours == 6 ? "checkmark" : "")
                }
                .disabled(!viewModel.canChangeHours)

                Button {
                    viewModel.hours = 12
                } label: {
                    Label("12 hours", systemImage: viewModel.hours == 12 ? "checkmark" : "")
                }
                .disabled(!viewModel.canChangeHours)

                Button {
                    viewModel.hours = 24
                } label: {
                    Label("24 hours", systemImage: viewModel.hours == 24 ? "checkmark" : "")
                }
                .disabled(!viewModel.canChangeHours)

                Divider()

                Button {
                    viewModel.truncatedYAxis.toggle()
                } label: {
                    Label("Display truncated Y axis", systemImage: viewModel.truncatedYAxis ? "checkmark" : "")
                }
            } label: {
                NonFunctionalButton {
                    Image(systemName: "list.bullet")
                        .frame(minWidth: 22)
                        .frame(height: 20)
                }
            }

            DatePicker("Choose date", selection: $viewModel.candidateQueryDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .frame(height: 23)
                .labelsHidden()
                .accessibilityLabel("accessibility.stats.datepicker.day")

            Spacer()

            Button {
                viewModel.decrease()
            } label: {
                Image(systemName: "chevron.left")
                    .frame(minWidth: 22)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("accessibility.previous.day")

            Button {
                viewModel.increase()
            } label: {
                Image(systemName: "chevron.right")
                    .frame(minWidth: 22)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canIncrease)
            .accessibilityLabel("accessibility.next.day")
        }
    }
}

#Preview {
    VStack {
        ParameterGraphHeaderView(
            viewModel: ParameterGraphHeaderViewModel(
                displayMode: .init(date: .now, hours: 6),
                configManager: ConfigManager.preview(),
                onChange: { _ in }
            ),
            showingVariables: .constant(false)
        )
        Spacer()
    }
}
