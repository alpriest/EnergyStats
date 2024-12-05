//
//  TemperatureView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/12/2024.
//

import Energy_Stats_Core
import SwiftUI

struct TemperatureView: View {
    let value: Double?
    let name: String
    let accessibilityLabel: String
    let showName: Bool

    var body: some View {
        if let formattedValue {
            VStack(alignment: .center) {
                Text(formattedValue + "℃")
                    .font(showName ? .caption : .body)

                if showName {
                    Text(name.uppercased())
                        .font(.system(size: 8.0))
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(accessibilityLabel) + Text(" \(name) ") + Text("accessibility.temperature") + Text(" \(formattedValue) ℃"))
        }
    }

    var formattedValue: String? {
        guard let value else { return "" }

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}
