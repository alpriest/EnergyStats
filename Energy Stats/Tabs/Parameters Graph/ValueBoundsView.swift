//
//  ValueBoundsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/07/2023.
//

import SwiftUI
import Energy_Stats_Core

enum BoundType: String, RawRepresentable {
    case min
    case max
    case now
}

struct ValueBoundsView: View {
    let value: Double?
    let type: BoundType
    let decimalPlaces: Int

    var body: some View {
        if let value {
            SubLabelledView(
                value: value.roundedToString(decimalPlaces: decimalPlaces),
                label: type.rawValue.uppercased(),
                alignment: .trailing
            )
        }
    }
}

struct SubLabelledView: View {
    let value: String
    let label: String
    let alignment: HorizontalAlignment

    init(value: String, label: String, alignment: HorizontalAlignment) {
        self.value = value
        self.label = label
        self.alignment = alignment
    }

    init(
        value: Double?,
        label: String,
        appSettings: AppSettings,
        alignment: HorizontalAlignment,
        decimalPlaceOverride: Int
    ) {
        self.value = value?.roundedToString(decimalPlaces: decimalPlaceOverride) ?? ""
        self.label = label
        self.alignment = alignment
    }

    var body: some View {
        VStack(alignment: alignment) {
            Text(value)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 8.0))
        }
    }
}

#Preview {
    HStack {
        ValueBoundsView(value: 0.3, type: .min, decimalPlaces: 1)
        ValueBoundsView(value: 23.3, type: .max, decimalPlaces: 3)
    }
}
