//
//  CustomDatePicker.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/12/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct CustomTimePicker: View {
    @Binding var start: Date
    @Binding var end: Date
    private let includeSeconds: Bool
    @State private var showing: TimeType?

    init(start: Binding<Date>, end: Binding<Date>, includeSeconds: Bool) {
        self._start = start
        self._end = end
        self.includeSeconds = includeSeconds
    }

    var body: some View {
        SingleTimePickerView(
            label: "Start",
            date: $start,
            timeType: .start,
            includeAppendage: includeSeconds,
            showing: $showing
        )

        SingleTimePickerView(
            label: "End",
            date: $end,
            timeType: .end,
            includeAppendage: includeSeconds,
            showing: $showing
        )
    }
}

private struct SingleTimePickerView: View {
    let label: LocalizedStringKey
    @Binding var date: Date
    private let timeType: TimeType
    private let includeAppendage: Bool
    @Binding var showing: TimeType?

    init(
        label: LocalizedStringKey,
        date: Binding<Date>,
        timeType: TimeType,
        includeAppendage: Bool,
        showing: Binding<TimeType?>
    ) {
        self.label = label
        self._date = date
        self.timeType = timeType
        self.includeAppendage = includeAppendage
        self._showing = showing
    }

    var body: some View {
        VStack {
            HStack {
                Text(label)
                Spacer()
                Text(date, formatter: DateFormatter.fullTime) + Text(includeAppendage ? ":" + timeType.appendage() : "")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if showing != timeType {
                    showing = timeType
                } else {
                    showing = nil
                }
            }

            if showing == timeType {
                TimePickerSheet(label: label, date: $date)
            }
        }
    }
}

private struct TimePickerSheet: View {
    let label: LocalizedStringKey
    @Binding var date: Date
    @AppStorage("timeStyleAccurate") private var timeStyleAccurate = true

    init(label: LocalizedStringKey, date: Binding<Date>) {
        self.label = label
        self._date = date
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
        }
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
    Preview()
}

private struct Preview: View {
    @State var start = Date()
    @State var end = Date()

    var body: some View {
        CustomTimePicker(
            start: $start,
            end: $end,
            includeSeconds: true
        )
    }
}
