//
//  CustomDateRangePickerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/12/2025.
//

import Energy_Stats_Core
import SwiftUI

struct CustomDateRangePickerView: View {
    @State var start: Date
    @State var end: Date
    @State private var dirty = false
    @State private var chooseBy = CustomDateRangeDisplayUnit.months
    @State private var startHeader: LocalizedStringKey = ""
    @State private var endHeader: LocalizedStringKey = ""
    @State private var viewByFooter: LocalizedStringKey = ""
    @State private var errorMessage: LocalizedStringKey? = nil
    private let initialStart: Date
    private let initialEnd: Date
    private let onUpdate: (Date, Date, CustomDateRangeDisplayUnit) -> Void
    private let onCancel: () -> Void

    init(
        start: Date,
        end: Date,
        onUpdate: @escaping (Date, Date, CustomDateRangeDisplayUnit) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.start = start
        self.end = end
        self.initialStart = start
        self.initialEnd = end
        self.onUpdate = onUpdate
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Button {
                        end = Date.now.endOfMonth()
                        let startCandidate = Calendar.current.date(byAdding: .month, value: -12, to: end) ?? end
                        start = startCandidate.startOfMonth()
                        chooseBy = .months
                    } label: {
                        Text("Last 12 months")
                    }

                    Button {
                        end = Date.now.endOfMonth()
                        let startCandidate = Calendar.current.date(byAdding: .month, value: -6, to: end) ?? end
                        start = startCandidate.startOfMonth()
                        chooseBy = .months
                    } label: {
                        Text("Last 6 months")
                    }
                } header: {
                    Text("Quick choice")
                }

                Section {
                    Picker("View by", selection: $chooseBy) {
                        ForEach(CustomDateRangeDisplayUnit.allCases, id: \.self) {
                            Text($0.title).tag($0)
                        }
                    }.pickerStyle(.segmented)
                } header: {
                    Text("View by")
                } footer: {
                    Text(viewByFooter)
                }

                if chooseBy == .days {
                    Group {
                        Section {
                            SingleDatePickerView(label: startHeader, date: $start)
                        } header: {
                            Text(startHeader)
                        }

                        Section {
                            SingleDatePickerView(label: endHeader, date: $end)
                        } header: {
                            Text(endHeader)
                        }
                    }
                } else if chooseBy == .months {
                    Group {
                        Section {
                            YearMonthPickerView(
                                selectedYear: .init(
                                    get: { start.year },
                                    set: { start = Date.from(year: $0, month: start.month).startOfMonth() }
                                ),
                                selectedMonth: .init(
                                    get: { start.month },
                                    set: { start = Date.from(year: start.year, month: $0).startOfMonth() }
                                )
                            )
                            .labelsHidden()
                        } header: {
                            Text(startHeader)
                        }

                        Section {
                            YearMonthPickerView(
                                selectedYear: .init(
                                    get: { end.year },
                                    set: { end = Date.from(year: $0, month: end.month).endOfMonth() }
                                ),
                                selectedMonth: .init(
                                    get: { end.month },
                                    set: { end = Date.from(year: end.year, month: $0).endOfMonth() }
                                )
                            )
                            .labelsHidden()
                        } header: {
                            Text(endHeader)
                        }
                    }
                }

            }.onChange(of: start) { _ in
                recompute()
            }
            .onChange(of: end) { _ in
                recompute()
            }
            .onChange(of: chooseBy) { _ in
                recompute()
            }
            .onAppear {
                recompute()
            }

            BottomButtonsView(dirty: dirty, onApply: {
                onUpdate(start, end, chooseBy)
            }, footer: makeFooter)
        }
    }

    @ViewBuilder
    private func makeFooter() -> some View {
        VStack {
            Text("\(chooseBy.formatted(start)) - \(chooseBy.formatted(end))")
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(datesAreValid() ? Color.primary : Color.errorText)
            }
        }
    }

    private func recompute() {
        switch chooseBy {
        case .days:
            startHeader = "Start day"
            endHeader = "End day"
            viewByFooter = "Shows a range of days. Maximum of 45 days"
        case .months:
            startHeader = "Start month"
            endHeader = "End month"
            viewByFooter = "Shows a range of months"
        }
        errorMessage = makeErrorMessage()

        recomputeDirty()
    }

    private func recomputeDirty() {
        dirty = ((start != initialStart) || (end != initialEnd)) && datesAreValid()
    }
    
    private func datesAreValid() -> Bool {
        makeErrorMessage() == nil
    }

    private func makeErrorMessage() -> LocalizedStringKey? {
        guard end > start else { return "Please ensure the start date is before the end date." }
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0

        if chooseBy == .days && days > 45 {
            return "Please choose months or a shorter date range."
        }

        return nil
    }
}

#Preview {
    CustomDateRangePickerView(
        start: Date.now.addingTimeInterval(0 - (31 * 86400)),
        end: Date.now,
        onUpdate: { _, _, _ in },
        onCancel: {}
    )
    .environment(\.locale, .init(identifier: "de"))
}

enum CustomDateRangeDisplayUnit: CaseIterable {
    case days
    case months

    var title: LocalizedStringKey {
        switch self {
        case .days:
            "Days"
        case .months:
            "Months"
        }
    }

    func formatted(_ date: Date) -> String {
        let formatter = switch self {
        case .days:
            Date.FormatStyle.dayMonth
        case .months:
            Date.FormatStyle.monthYear
        }
        return date.formatted(formatter)
    }
}

private struct SingleDatePickerView: View {
    let label: LocalizedStringKey
    @Binding var date: Date

    init(label: LocalizedStringKey, date: Binding<Date>) {
        self.label = label
        self._date = date
    }

    var body: some View {
        DatePicker(label, selection: $date, displayedComponents: [.date])
            .datePickerStyle(.graphical)
    }
}
