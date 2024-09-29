//
//  SummaryDateRangeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 28/09/2024.
//

import SwiftUI
import Energy_Stats_Core

struct SummaryDateRangeView: View {
    @State private var automatic = false
    @State private var from: Date = .distantPast
    @State private var to: Date = .now
    @Environment(\.presentationMode) var presentationMode
    let onApply: (SummaryDateRange) -> Void

    init(initial: SummaryDateRange, onApply: @escaping (SummaryDateRange) -> Void) {
        switch initial {
        case .automatic:
            self.automatic = true
        case let .manual(from: from, to: to):
            self.automatic = false
            self.from = from
            self.to = to
        }
        self.onApply = onApply
    }

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
                onApply(makeDateRange())
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Apply")
                    .frame(minWidth: 0, maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
        }.padding()
    }

    func makeDateRange() -> SummaryDateRange {
        if automatic {
            SummaryDateRange.automatic
        } else {
            SummaryDateRange.manual(from: from, to: to)
        }
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
    SummaryDateRangeView(initial: .automatic, onApply: { _ in })
}
