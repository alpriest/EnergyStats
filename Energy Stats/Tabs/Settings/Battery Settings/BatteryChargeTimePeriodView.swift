//
//  BatteryChargeTimePeriodView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct BatteryChargeTimePeriodView: View {
    @Binding var timePeriod: ChargeTimePeriod
    @State private var errorMessage: String?

    private let title: LocalizedStringKey

    init(timePeriod: Binding<ChargeTimePeriod>, title: LocalizedStringKey) {
        self._timePeriod = timePeriod
        self.title = title
    }

    var body: some View {
        Section(
            content: {
                Toggle(isOn: $timePeriod.enabled, label: { Text("Enable charge from grid") })

                CustomTimePicker(start: $timePeriod.start, end: $timePeriod.end, includeSeconds: false)
            },
            header: {
                Text(title)
            },
            footer: {
                VStack(alignment: .leading) {
                    Button("Reset times") {
                        timePeriod.start = Date.fromTime(Time.zero())
                        timePeriod.end = Date.fromTime(Time.zero())
                    }.buttonStyle(.bordered)
                }
            }
        )
    }
}

struct BatteryChargeTimePeriodView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var period = ChargeTimePeriod(start: Date(), end: Date(), enabled: true)
        var body: some View {
            Form {
                BatteryChargeTimePeriodView(
                    timePeriod: $period,
                    title: "Period 1"
                )
            }
        }
    }
}
