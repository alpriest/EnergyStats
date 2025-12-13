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
    private let initialStart: Date
    private let initialEnd: Date
    private let onUpdate: (Date, Date) -> Void
    private let onCancel: () -> Void

    init(
        start: Date,
        end: Date,
        onUpdate: @escaping (Date, Date) -> Void,
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
        VStack {
            Form {
                Section {
                    SingleDatePickerView(label: "Start", date: $start)
                } header: {
                    Text("Start")
                }
                
                Section {
                    SingleDatePickerView(label: "End", date: $end)
                } header: {
                    Text("End")
                }
            }.onChange(of: start) { _ in
                recomputeDirty()
            }
            .onChange(of: end) { _ in
                recomputeDirty()
            }
            .onAppear {
                recomputeDirty()
            }

            BottomButtonsView(dirty: dirty) {
                onUpdate(start, end)
            }
        }
    }

    private func recomputeDirty() {
        dirty = (start != initialStart) || (end != initialEnd)
    }
}

#Preview {
    CustomDateRangePickerView(
        start: Date.now.addingTimeInterval(0 - (31 * 86400)),
        end: Date.now,
        onUpdate: { _, _ in },
        onCancel: { }
    )
}

enum CustomDateRangeDisplayUnit: CaseIterable {
    case days
    case months
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
