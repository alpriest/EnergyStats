//
//  SummaryDateRangeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 28/09/2024.
//

import Energy_Stats_Core
import SwiftUI

struct SummaryDateRangeView: View {
    @State private var automatic = false
    @State private var from: Date = .now
    @State private var to: Date = .now
    @Environment(\.presentationMode) var presentationMode
    let onApply: (SummaryDateRange) -> Void

    init(initial: SummaryDateRange, onApply: @escaping (SummaryDateRange) -> Void) {
        switch initial {
        case .automatic:
            self.automatic = true
            self.from = Date.from(year: 2020, month: 1)
            self.to = .now
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

                    YearMonthPickerView(date: $from)
                }

                HStack {
                    Text("To")
                    Spacer()

                    YearMonthPickerView(date: $to)
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
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @Binding private var date: Date

    init(date: Binding<Date>) {
        self._date = date
        self.selectedYear = date.wrappedValue.year
        self.selectedMonth = date.wrappedValue.month
    }

    // Define range for years and months
    let years = 2020 ... (Calendar.current.component(.year, from: .now))
    let months: [String] = DateFormatter().monthSymbols

    var body: some View {
        HStack {
            // Month Picker
            Picker("Month", selection: $selectedMonth) {
                ForEach(1 ..< 13) { month in
                    Text(months[month - 1]).tag(month)
                }
            }
            .pickerStyle(.menu)
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
        }.onChange(of: selectedYear) {
            self.date = Date.from(year: $0, month: selectedMonth)
        }.onChange(of: selectedMonth) {
            self.date = Date.from(year: selectedYear, month: $0)
        }
    }
}

#Preview {
    SummaryDateRangeView(initial: .automatic, onApply: { _ in })
}
