//
//  ParameterGraphHeaderView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct ParameterGraphHeaderView: View {
    @State private var hours: Int = 24
    @Binding var displayMode: GraphDisplayMode
    @State private var candidateQueryDate = Date()
    @Binding var showingVariables: Bool

    init(displayMode: Binding<GraphDisplayMode>, showingVariables: Binding<Bool>) {
        self._displayMode = displayMode
        self._showingVariables = showingVariables

        self.candidateQueryDate = displayMode.wrappedValue.date
        self.hours = displayMode.wrappedValue.hours
    }

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

                DatePicker("Choose date", selection: $candidateQueryDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .frame(height: 23)
                    .labelsHidden()

                Menu {
                    Button {
                        hours = 6
                        displayMode = .init(date: candidateQueryDate, hours: hours)
                    } label: {
                        Label("6 hours", systemImage: hours == 6 ? "checkmark" : "")
                    }

                    Button {
                        hours = 12
                        displayMode = .init(date: candidateQueryDate, hours: hours)
                    } label: {
                        Label("12 hours", systemImage: hours == 12 ? "checkmark" : "")
                    }

                    Button {
                        hours = 24
                        displayMode = .init(date: candidateQueryDate, hours: hours)
                    } label: {
                        Label("24 hours", systemImage: hours == 24 ? "checkmark" : "")
                    }
                } label: {
                    NonFunctionalButton {
                        Image(systemName: "clock")
                            .frame(minWidth: 22)
                    }
                }
                .disabled(!Calendar.current.isDate(candidateQueryDate, inSameDayAs: .now))

                Button {
                    hours = 24
                    candidateQueryDate = candidateQueryDate.addingTimeInterval(-86400)
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(minWidth: 22)
                }.buttonStyle(.bordered)

                Button {
                    hours = 24
                    candidateQueryDate = candidateQueryDate.addingTimeInterval(86400)
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(minWidth: 22)
                }.buttonStyle(.bordered)
            }
            .onChange(of: candidateQueryDate) { newValue in
                displayMode = .init(date: newValue, hours: hours)
            }
        }
        .padding(.horizontal)
    }
}

@available(iOS 16.0, *)
struct GraphHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ParameterGraphHeaderView(displayMode: .constant(GraphDisplayMode(date: .now, hours: 6)), showingVariables: .constant(false))
        }
    }
}
