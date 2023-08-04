//
//  BatteryTimePeriodView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI
import Energy_Stats_Core

struct BatteryTimePeriodView: View {
    @Binding var timePeriod: ChargeTimePeriod
    @State private var timeError = false
    @State private var errorMessage: String?
    let title: String

    var body: some View {
        Section(
            content: {
                Toggle(isOn: $timePeriod.enabled, label: { Text("Enable charge from grid") })

                DatePicker("Start", selection: $timePeriod.start, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.compact)
                    .tinted(enabled: $timeError)

                DatePicker("End", selection: $timePeriod.end, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.compact)
                    .tinted(enabled: $timeError)
            },
            header: {
                Text(title)
            },
            footer: {
                VStack(alignment: .leading) {
                    OptionalView(errorMessage) {
                        Text($0)
                            .foregroundColor(.red)
                            .padding(.bottom)
                    }

                    Button("Reset times") {
                        timePeriod.start = Date.fromTime(Time.zero())
                        timePeriod.end = Date.fromTime(Time.zero())
                    }.buttonStyle(.borderless)
                }
            }
        ).onChange(of: timePeriod) { newValue in
            timeError = !newValue.valid
            errorMessage = newValue.validate
        }
    }
}

struct BatteryTimePeriodView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var period = ChargeTimePeriod(start: Date(), end: Date(), enabled: true)
        var body: some View {
            Form {
                BatteryTimePeriodView(timePeriod: $period, title: "Period 1")
            }
        }
    }
}
