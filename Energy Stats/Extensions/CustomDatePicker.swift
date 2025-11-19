//
//  CustomDatePicker.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/12/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct CustomDatePicker: View {
    @Binding var start: Date
    @Binding var end: Date
    private let includeSeconds: Bool

    init(start: Binding<Date>, end: Binding<Date>, includeSeconds: Bool) {
        self._start = start
        self._end = end
        self.includeSeconds = includeSeconds
    }

    var body: some View {
        VStack {
            SinglePickerView(label: "Start", date: $start, timeType: .start, includeAppendage: includeSeconds)
            SinglePickerView(label: "End", date: $end, timeType: .end, includeAppendage: includeSeconds)
        }
    }
}

struct SinglePickerView: View {
    let label: LocalizedStringKey
    @Binding var date: Date
    @State private var showing = false
    private let timeType: TimeType
    private let includeAppendage: Bool

    init(label: LocalizedStringKey, date: Binding<Date>, timeType: TimeType, includeAppendage: Bool) {
        self.label = label
        self._date = date
        self.timeType = timeType
        self.includeAppendage = includeAppendage
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Button(action: {
                showing = true
            }) {
                Text(date, formatter: DateFormatter.fullTime) + Text(includeAppendage ? ":" + timeType.appendage() : "")
            }.buttonStyle(.bordered)
        }.onTapGesture {
            showing = true
        }.sheet(isPresented: $showing, content: {
            DatePickerSheet(label: label, date: date) {
                date = $0
                showing = false
            }
        })
    }
}

struct DatePickerSheet: View {
    let label: LocalizedStringKey
    @State var date: Date
    let onSelect: (Date) -> Void
    @AppStorage("timeStyleAccurate") private var timeStyleAccurate = true
    private let originalValue: Date
    @State private var isDirty = false

    init(label: LocalizedStringKey, date: Date, onSelect: @escaping (Date) -> Void) {
        self.label = label
        originalValue = date
        self._date = State(wrappedValue: date)
        self.onSelect = onSelect
    }

    var body: some View {
        VStack {
            Picker("Accuracy", selection: $timeStyleAccurate) {
                Text("Accurate")
                    .tag(true)

                Text("Half-hourly")
                    .tag(false)
            }.pickerStyle(.segmented)

            switch timeStyleAccurate {
            case true:
                DatePicker(label, selection: $date, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            case false:
                Picker(label, selection: $date) {
                    ForEach(timeSlots, id: \.self) {
                        Text($0.formatted(type: nil)).tag($0.toDate())
                    }
                }.pickerStyle(.wheel)
            }

            Spacer()

            BottomButtonsView(dirty: isDirty) {
                onSelect(date)
            }
        }
        .onChange(of: date) { newValue in
            isDirty = newValue != originalValue
        }
        .padding()
        .modifier(MediumPresentationDetentsViewModifier())
    }

    private let timeSlots: [Time] = {
        var timeSlots: [Time] = []

        for hour in 0 ..< 24 {
            for minute in [0, 30] {
                timeSlots.append(Time(hour: hour, minute: minute))
            }
        }

        return timeSlots
    }()
}

struct MediumPresentationDetentsViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.presentationDetents([.medium])
    }
}

#Preview {
    CustomDatePicker(
        start: .constant(Date()),
        end: .constant(
            Date()
        ),
        includeSeconds: true
    )
}
