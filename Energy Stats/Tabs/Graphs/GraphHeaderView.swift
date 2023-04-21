//
//  GraphHeaderView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct GraphHeaderView: View {
    @State private var hours: Int = 24
    @Binding var displayMode: GraphDisplayMode
    @State private var datePickerVisible = false
    @State private var candidateQueryDate = Date()
    @State private var dateChoice: String = "today"

    init(displayMode: Binding<GraphDisplayMode>) {
        self._displayMode = displayMode

        switch displayMode.wrappedValue {
        case .today(let hours):
            self.hours = hours
        case .historic(let date):
            self.candidateQueryDate = date
        }
    }

    var body: some View {
        VStack {
            Picker("Choose", selection: $dateChoice) {
                Text("Past").tag("past")
                Text("Today").tag("today")
            }
            .pickerStyle(.segmented)
            .onChange(of: dateChoice, perform: { choice in
                if choice == "today" {
                    displayMode = .today(hours)
                } else {
                    displayMode = .historic(candidateQueryDate)
                }
            })

            if dateChoice == "today" {
                Picker("Hours", selection: $hours) {
                    Text("6h").tag(6)
                    Text("12h").tag(12)
                    Text("24h").tag(24)
                }
                .font(.body)
                .pickerStyle(.segmented)
                .onChange(of: hours) { newValue in
                    displayMode = .today(newValue)
                }
            } else {
                HStack {
                    Button {
                        candidateQueryDate = candidateQueryDate.addingTimeInterval(-86400)
                    } label: {
                        Image(systemName: "chevron.left")
                            .frame(width: 44)
                    }.buttonStyle(.bordered)

                    Button {
                        candidateQueryDate = candidateQueryDate.addingTimeInterval(86400)
                    } label: {
                        Image(systemName: "chevron.right")
                            .frame(width: 44)
                    }.buttonStyle(.bordered)

                    DatePicker("Choose date", selection: $candidateQueryDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .frame(height: 23)
                        .labelsHidden()
                }
                .onChange(of: candidateQueryDate) { newValue in
                    displayMode = .historic(newValue)
                }
            }
        }
    }
}

struct GraphHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            GraphHeaderView(displayMode: .constant(.today(6)))
        }
    }
}
