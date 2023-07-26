//
//  BatteryForceChargeSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

struct BatteryForceChargeSettingsView: View {
    @Binding var timePeriod1: ChargeTimePeriod
    @Binding var timePeriod2: ChargeTimePeriod

    var body: some View {
        BatteryTimePeriodView(timePeriod: $timePeriod1, title: "Force charge period 1")
        BatteryTimePeriodView(timePeriod: $timePeriod2, title: "Force charge period 2")

        Section(content: {}, footer: {
            VStack {
                Button(action: {}, label: {
                    Text("Save")
                        .frame(minWidth: 0, maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .disabled(!timePeriod1.valid || !timePeriod2.valid)
            }
        })
    }
}

struct BatteryForceChargeSettingsView_Previews: PreviewProvider {
    struct Preview: View {
        @State private var period1 = ChargeTimePeriod(enabled: true)
        @State private var period2 = ChargeTimePeriod(enabled: false)

        var body: some View {
            Form {
                BatteryForceChargeSettingsView(
                    timePeriod1: $period1,
                    timePeriod2: $period2
                )
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
