//
//  ValueBoundsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/07/2023.
//

import SwiftUI

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

    var body: some View {
        VStack(alignment: alignment) {
            Text(value)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 8.0))
        }
    }
}

struct ValueBoundsView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ValueBoundsView(value: 0.3, type: .min, decimalPlaces: 1)
            ValueBoundsView(value: 23.3, type: .max, decimalPlaces: 3)
        }
    }
}
