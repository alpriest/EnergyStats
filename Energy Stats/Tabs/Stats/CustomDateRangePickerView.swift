//
//  CustomDateRangePickerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/12/2025.
//

import SwiftUI

struct CustomDateRangePickerView: View {
    @State var from: Date
    @State var end: Date
    @State private var dirty = false
    private let initialStart: Date
    private let initialEnd: Date
    private let onUpdate: (Date, Date) -> Void
    private let onCancel: () -> Void
    @State private var chooseBy = CustomDateRangeDisplayUnit.months

    init(
        start: Date,
        end: Date,
        onUpdate: @escaping (Date, Date) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.from = start
        self.end = end
        self.initialStart = start
        self.initialEnd = end
        self.onUpdate = onUpdate
        self.onCancel = onCancel
    }

    var body: some View {
        VStack {
            Form {
                Section {
                    Button {
                        end = .now
                        from = Calendar.current.date(byAdding: .month, value: -12, to: end) ?? end
                    } label: {
                        Text("Last 12 months")
                    }

                    Button {
                        end = .now
                        from = Calendar.current.date(byAdding: .month, value: -6, to: end) ?? end
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
                }

                if chooseBy == .days {
                    Group {
                        Section {
                            SingleDatePickerView(label: "Start", date: $from)
                        } header: {
                            Text("Start")
                        }

                        Section {
                            SingleDatePickerView(label: "End", date: $end)
                        } header: {
                            Text("End")
                        }
                    }
                } else if chooseBy == .months {
                    Group {
                        Section {
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
                            .labelsHidden()
                        } header: {
                            Text("Start")
                        }

                        Section {
                            YearMonthPickerView(
                                selectedYear: .init(
                                    get: { end.year },
                                    set: { end = Date.from(year: $0, month: end.month) }
                                ),
                                selectedMonth: .init(
                                    get: { end.month },
                                    set: { end = Date.from(year: end.year, month: $0) }
                                )
                            )
                            .labelsHidden()
                        } header: {
                            Text("End")
                        }
                    }
                }

            }.onChange(of: from) { _ in
                recomputeDirty()
            }
            .onChange(of: end) { _ in
                recomputeDirty()
            }
            .onAppear {
                recomputeDirty()
            }

            BottomButtonsView(dirty: dirty) {
                onUpdate(from, end)
            }
        }
    }

    private func recomputeDirty() {
        dirty = (from != initialStart) || (end != initialEnd)
    }
}

#Preview {
    CustomDateRangePickerView(
        start: Date.now.addingTimeInterval(0 - (31 * 86400)),
        end: Date.now,
        onUpdate: { _, _ in },
        onCancel: {}
    )
}

enum CustomDateRangeDisplayUnit: CaseIterable {
    case days
    case months

    var title: String {
        switch self {
        case .days:
            "Days"
        case .months:
            "Months"
        }
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
