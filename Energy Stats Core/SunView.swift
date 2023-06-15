//
//  SunView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/05/2023.
//

import SwiftUI

public struct SunView: View {
    var solar: Double
    let glowing: Bool
    let glowColor: Color
    let sunColor: Color

    public init(solar: Double, glowing: Bool, glowColor: Color, sunColor: Color) {
        self.solar = solar
        self.glowing = glowing
        self.glowColor = glowColor
        self.sunColor = sunColor
    }

    public var body: some View {
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

struct Glowing: ViewModifier {
    let active: Bool
    let color: Color
    let radius: CGFloat

    @ViewBuilder func body(content: Content) -> some View {
        if active {
            content
                .shadow(color: color, radius: radius / 2)
                .shadow(color: color, radius: radius / 2)
        } else {
            content
        }
    }
}

extension View {
    func glow(active: Bool, color: Color = .yellow, radius: CGFloat = 20) -> some View {
        modifier(Glowing(active: active, color: color, radius: radius))
    }
}
