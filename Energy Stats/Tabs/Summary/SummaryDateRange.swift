//
//  SummaryDateRange.swift
//  Energy Stats
//
//  Created by Alistair Priest on 28/09/2024.
//

import SwiftUI

struct SummaryDateRange: View {
    @State private var automatic = false
    @State private var from: Date = .distantPast
    @State private var to: Date = .now
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Choose summary date range")
                .font(.title)

            Toggle(isOn: $automatic) { Text("Automatic") }
                .padding(.bottom)

            Group {
                HStack {
                    Text("From")
                    Spacer()

                    YearMonthPickerView()
                }

                HStack {
                    Text("To")
                    Spacer()

                    YearMonthPickerView()
                }
            }
            .disabled(automatic)
            .foregroundStyle(automatic ? Color.primary.opacity(0.25) : .primary)

            Spacer()

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Apply")
                    .frame(minWidth: 0, maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
        }.padding()
    }
}

struct YearMonthPickerView: View {
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())

    // Define range for years and months
    let years = 2010 ... (Calendar.current.component(.year, from: .now))
    let months: [String] = DateFormatter().monthSymbols

    var body: some View {
        VStack {
            HStack {
                // Month Picker
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1 ..< 13) { month in
                        Text(months[month - 1]).tag(month)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 150)
                .clipped()

                // Year Picker
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text(String(describing: year)).tag(year)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 100)
                .clipped()
            }
            .padding()
        }
    }
}

#Preview {
    SummaryDateRange()
}
