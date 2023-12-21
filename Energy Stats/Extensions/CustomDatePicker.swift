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
    private let appSettingsPublisher: LatestAppSettingsPublisher
    @State private var appSettings: AppSettings = .mock()

    init(start: Binding<Date>, end: Binding<Date>, appSettingsPublisher: LatestAppSettingsPublisher) {
        self._start = start
        self._end = end
        self.appSettingsPublisher = appSettingsPublisher
        self.appSettings = appSettingsPublisher.value
    }

    var body: some View {
        if true {
            Picker("Start", selection: $start) {
                ForEach(timeSlots, id: \.self) {
                    Text($0.formatted).tag($0.toDate())
                }
            }

            Picker("End", selection: $end) {
                ForEach(timeSlots, id: \.self) {
                    Text($0.formatted).tag($0.toDate())
                }
            }
        } else {
            DatePicker("Start", selection: $start, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)

            DatePicker("End", selection: $end, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
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
        ),
        appSettingsPublisher: CurrentValueSubject(.mock().copy(showHalfHourlyTimeSelectors: false))
    )
}
