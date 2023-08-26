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

    var body: some View {
        if let value {
            VStack(alignment: .trailing) {
                Text(value, format: .number)
                Text(type.rawValue.uppercased())
                    .font(.system(size: 8.0))
            }
        }
    }
}

struct ValueBoundsView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ValueBoundsView(value: 0.3, type: .min)
            ValueBoundsView(value: 23.3, type: .max)
        }
    }
}
