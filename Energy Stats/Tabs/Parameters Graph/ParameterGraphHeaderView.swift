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
        Group {
            HStack {
                Button {
                    showingVariables.toggle()
                } label: {
                    Image(systemName: "checklist")
                        .frame(minWidth: 22)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("variable_chooser")

                DatePicker("Choose date", selection: $viewModel.candidateQueryDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .frame(height: 23)
                    .labelsHidden()

                Menu {
                    Button {
                        viewModel.hours = 6
                    } label: {
                        Label("6 hours", systemImage: viewModel.hours == 6 ? "checkmark" : "")
                    }

                    Button {
                        viewModel.hours = 12
                    } label: {
                        Label("12 hours", systemImage: viewModel.hours == 12 ? "checkmark" : "")
                    }

                    Button {
                        viewModel.hours = 24
                    } label: {
                        Label("24 hours", systemImage: viewModel.hours == 24 ? "checkmark" : "")
                    }
                } label: {
                    NonFunctionalButton {
                        Image(systemName: "clock")
                            .frame(minWidth: 22)
                    }
                }
                .disabled(!viewModel.canChangeHours)

                Button {
                    viewModel.decrease()
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(minWidth: 22)
                }.buttonStyle(.bordered)

                Button {
                    viewModel.increase()
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(minWidth: 22)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canIncrease)
            }
        }
        .padding(.horizontal)
    }
}

@available(iOS 16.0, *)
struct GraphHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ParameterGraphHeaderView(viewModel: ParameterGraphHeaderViewModel(displayMode: .constant(.init(date: .now, hours: 6))), showingVariables: .constant(false))
        }
    }
}
