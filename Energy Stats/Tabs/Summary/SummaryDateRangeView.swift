//
//  SummaryDateRangeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 28/09/2024.
//

import Energy_Stats_Core
import SwiftUI

struct SummaryDateRangeView: View {
    @State private var automatic: Bool
    @State private var from: Date
    @State private var to: Date
    @Environment(\.presentationMode) var presentationMode
    let onApply: (SummaryDateRange) -> Void
    @State private var canApply: Bool

    init(initial: SummaryDateRange, onApply: @escaping (SummaryDateRange) -> Void) {
        self.onApply = onApply

        let automatic: Bool
        let from: Date
        let to: Date

        switch initial {
        case .automatic:
            automatic = true
            from = Date.from(year: 2020, month: 1)
            to = .now
        case let .manual(from: initialFrom, to: initialTo):
            automatic = false
            from = initialFrom
            to = initialTo
        }

        _automatic = State(initialValue: automatic)
        _from = State(initialValue: from)
        _to = State(initialValue: to)
        _canApply = State(initialValue: Self.makeCanApply(from: from, to: to))
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
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canApply)
        }
        .padding()
        .onChange(of: from) {
            canApply = Self.makeCanApply(from: from, to: to)
        }
        .onChange(of: to) {
            canApply = Self.makeCanApply(from: from, to: to)
        }
    }

    func makeDateRange() -> SummaryDateRange {
        if automatic {
            SummaryDateRange.automatic
        } else {
            SummaryDateRange.manual(from: from, to: to)
        }
    }

    private static func makeCanApply(from: Date, to: Date) -> Bool {
        from <= to
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
                ForEach(1 ..< 13) { month in
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
