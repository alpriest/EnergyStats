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

    init(start: Binding<Date>, end: Binding<Date>) {
        self._start = start
        self._end = end
    }

    var body: some View {
        VStack {
            SinglePickerView(label: "Start", date: $start)
            SinglePickerView(label: "End", date: $end)
        }
    }
}

struct SinglePickerView: View {
    let label: LocalizedStringKey
    @Binding var date: Date
    @State private var showing = false

    init(label: LocalizedStringKey, date: Binding<Date>) {
        self.label = label
        self._date = date
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Button(action: {
                showing = true
            }) {
                Text(date, formatter: DateFormatter.fullTime)
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

    init(label: LocalizedStringKey, date: Date, onSelect: @escaping (Date) -> Void) {
        self.label = label
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
                        Text($0.formatted).tag($0.toDate())
                    }
                }.pickerStyle(.wheel)
            }

            Spacer()

            BottomButtonsView {
                onSelect(date)
            }
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
        if #available(iOS 16.0, *) {
            content.presentationDetents([.medium])
        } else {
            content
        }
    }
}

#Preview {
    CustomDatePicker(
        start: .constant(Date()),
        end: .constant(
            Date()
        )
    )
}
