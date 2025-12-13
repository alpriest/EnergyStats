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

                    YearMonthPickerView(
                        selectedYear: .init(
                            get: { from.year },
                            set: { from = Date.from(year: $0, month: from.month) }
                        ),
                        selectedMonth: .init(
                            get: { from.month },
                            set: { from = Date.from(year: from.year, month: $0) }
                        )
                    )
                }

                HStack {
                    Text("To")
                    Spacer()

                    YearMonthPickerView(
                        selectedYear: .init(
                            get: { to.year },
                            set: { to = Date.from(year: $0, month: to.month) }
                        ),
                        selectedMonth: .init(
                            get: { to.month },
                            set: { to = Date.from(year: to.year, month: $0) }
                        )
                    )
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
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
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
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int

    var months: [String] { DateFormatter().monthSymbols }
    let years = 2020 ... Calendar.current.component(.year, from: .now)

    var body: some View {
        HStack {
            Picker("Month", selection: $selectedMonth) {
                ForEach(1..<13) { month in
                    Text(months[month - 1]).tag(month)
                }
            }
            .frame(minWidth: 170)
            .pickerStyle(.menu)
            .clipped()

            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(describing: year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)
            .clipped()
        }
    }
}

#Preview {
    SummaryDateRangeView(initial: .automatic, onApply: { _ in })
}
