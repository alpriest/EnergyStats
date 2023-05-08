//
//  SunView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/05/2023.
//

import SwiftUI

struct SunView: View {
    var solar: Double
    let glowing: Bool
    let glowColor: Color
    let sunColor: Color

    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .foregroundColor(sunColor)
                .frame(width: 23, height: 23)
                .glow(active: glowing, color: glowColor)

            ForEach(Array(stride(from: 0.0, to: .pi * 2, by: .pi / 4)), id: \.self) {
                RoundedRectangle(cornerRadius: 2.0)
                    .foregroundColor(sunColor)
                    .frame(width: 9, height: 4)
                    .offset(x: -20)
                    .rotationEffect(.degrees(($0 * 180) / .pi))
                    .glow(active: glowing, color: glowColor)
            }
        }
    }
}
