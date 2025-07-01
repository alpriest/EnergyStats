//
//  HomePowerView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 03/05/2024.
//

import SwiftUI

struct HomePowerView: View {
    let value: Double?
    let iconScale: IconScale

    var body: some View {
        FullPageStatusView(
            iconScale: iconScale,
            icon: {
                Image(systemName: "house.fill")
                    .font(houseSize)
                    .foregroundStyle(Color.iconDisabled)
                    .padding(iconScale == .large ? 10 : 0)
            },
            line1: {
                Group {
                    if let value {
                        Text(value.kW(2))
                    } else {
                        Text("xxxxx")
                            .redacted(reason: .placeholder)
                    }
                }
            },
            line2: { Text(" ") }
        )
    }

    private var houseSize: Font {
        switch iconScale {
        case .small:
            .system(size: 32)
        case .large:
            .system(size: 96)
        }
    }
}

#Preview {
    HomePowerView(value: 0.0, iconScale: .large)
}
