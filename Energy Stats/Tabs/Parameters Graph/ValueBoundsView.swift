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

#Preview {
    HStack {
        ValueBoundsView(value: 0.3, type: .min, decimalPlaces: 1)
        ValueBoundsView(value: 23.3, type: .max, decimalPlaces: 3)
    }
}
