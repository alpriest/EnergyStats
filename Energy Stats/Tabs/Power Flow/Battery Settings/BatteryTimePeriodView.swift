//
//  BatteryTimePeriodView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

struct BatteryTimePeriodView: View {
    @Binding var timePeriod: ChargeTimePeriod
    @State private var startError = false
    @State private var endError = false
    @State private var errorMessage: String?
    let title: String

    var body: some View {
        Section(
            content: {
                Toggle(isOn: $timePeriod.enabled, label: { Text("Enable charge from grid") })

                DatePicker("Start", selection: $timePeriod.start, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.compact)
                    .tinted(enabled: $startError)

                DatePicker("End", selection: $timePeriod.end, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.compact)
                    .tinted(enabled: $endError)
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

                    OptionalView(timePeriod.description) {
                        Text($0)
                    }
                }
            }
        ).onChange(of: timePeriod) { newValue in
            startError = newValue.start > timePeriod.end
            endError = timePeriod.end < newValue.start
            errorMessage = newValue.validate
        }
    }
}

struct BatteryTimePeriodView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var period = ChargeTimePeriod(enabled: true)
        var body: some View {
            Form {
                BatteryTimePeriodView(timePeriod: $period, title: "Period 1")
            }
        }
    }
}
