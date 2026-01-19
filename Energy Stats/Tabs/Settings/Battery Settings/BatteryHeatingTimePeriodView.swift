//
//  BatteryHeatingTimePeriodView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/01/2026.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct BatteryHeatingTimePeriodView: View {
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
                Toggle(isOn: $timePeriod.enabled.animation(), label: { Text("Enable heating") })

                if timePeriod.enabled {
                    CustomTimePicker(start: $timePeriod.start, end: $timePeriod.end, includeSeconds: false)
                }
            },
            header: {
                Text(title)
            }
        )
    }
}

struct BatteryHeatingTimePeriodView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var period = ChargeTimePeriod(start: Date(), end: Date(), enabled: true)
        var body: some View {
            Form {
                BatteryHeatingTimePeriodView(
                    timePeriod: $period,
                    title: "Period 1"
                )
            }
        }
    }
}
