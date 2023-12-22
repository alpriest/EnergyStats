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
    @AppStorage("showHighAccuracyTimePickers") private var accurate = false

    init(start: Binding<Date>, end: Binding<Date>) {
        self._start = start
        self._end = end
    }

    var body: some View {
        VStack {
            HStack {
                if accurate {
                    DatePicker("Start", selection: $start, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)
                } else {
                    Picker("Start", selection: $start) {
                        ForEach(timeSlots, id: \.self) {
                            Text($0.formatted).tag($0.toDate())
                        }
                    }
                }

                Button(action: { accurate.toggle() }) {
                    Image(systemName: "clock")
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 2)
            }

            HStack {
                if accurate {
                    DatePicker("End", selection: $end, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)
                } else {
                    Picker("End", selection: $end) {
                        ForEach(timeSlots, id: \.self) {
                            Text($0.formatted).tag($0.toDate())
                        }
                    }
                }

                Button(action: { accurate.toggle() }) {
                    Image(systemName: "clock")
                }
                .buttonStyle(.bordered)
                .padding(.vertical, 2)
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

#Preview {
    CustomDatePicker(
        start: .constant(Date()),
        end: .constant(
            Date()
        )
    )
}
