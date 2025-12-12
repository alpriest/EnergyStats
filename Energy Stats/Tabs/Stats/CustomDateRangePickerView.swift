//
//  CustomDateRangePickerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 11/12/2025.
//

import SwiftUI

struct CustomDateRangePickerView: View {
    @State var start: Date
    @State var end: Date
    @State private var dirty = false
    @State var displayUnit: CustomDateRangeDisplayUnit
    private let initialStart: Date
    private let initialEnd: Date
    private let initialDisplayUnit: CustomDateRangeDisplayUnit
    private let onUpdate: (Date, Date, CustomDateRangeDisplayUnit) -> Void

    init(start: Date, end: Date, displayUnit: CustomDateRangeDisplayUnit, onUpdate: @escaping (Date, Date, CustomDateRangeDisplayUnit) -> Void) {
        self.start = start
        self.end = end
        self.displayUnit = displayUnit
        self.initialStart = start
        self.initialEnd = end
        self.initialDisplayUnit = displayUnit
        self.onUpdate = onUpdate
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    SingleDatePickerView(label: "Start", date: $start)
                    SingleDatePickerView(label: "End", date: $end)

                    HStack {
                        Text("View as")

                        Picker("View as", selection: $displayUnit) {
                            ForEach(CustomDateRangeDisplayUnit.allCases, id: \.self) {
                                Text($0.title)
                            }
                        }.pickerStyle(.segmented)
                    }
                }
                .padding()
            }.onChange(of: start) { _ in
                recomputeDirty()
            }
            .onChange(of: end) { _ in
                recomputeDirty()
            }
            .onChange(of: displayUnit) { _ in
                recomputeDirty()
            }
            .onAppear {
                recomputeDirty()
            }

            BottomButtonsView(dirty: dirty) {
                onUpdate(start, end, displayUnit)
            }
        }
    }

    private func recomputeDirty() {
        dirty = (start != initialStart) || (end != initialEnd) || (displayUnit != initialDisplayUnit)
    }
}

#Preview {
    CustomDateRangePickerView(
        start: Date.now,
        end: Date.now,
        displayUnit: .days,
        onUpdate: { _, _, _ in
        }
    )
}

enum CustomDateRangeDisplayUnit: CaseIterable {
    case days
    case month

    var title: String {
        switch self {
        case .days:
            "Days"
        case .month:
            "Months"
        }
    }
}

private struct SingleDatePickerView: View {
    let label: LocalizedStringKey
    @Binding var date: Date
    @State private var showing = false

    init(label: LocalizedStringKey, date: Binding<Date>) {
        self.label = label
        self._date = date
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(label)

            DatePicker(label, selection: $date, displayedComponents: [.date])
                .datePickerStyle(.graphical)
        }
    }
}
