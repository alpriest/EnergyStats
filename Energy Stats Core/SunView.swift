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
    let sunSize: CGFloat

    public init(solar: Double, sunSize: CGFloat = 23) {
        self.solar = solar
        self.sunSize = sunSize

        switch solar {
        case 0.001 ..< 1.0:
            self.glowing = false
            self.glowColor = .clear
            self.sunColor = Color("Sun", bundle: Bundle(for: BundleLocator.self))
        case 1.0 ..< 2.0:
            self.glowing = true
            self.glowColor = .yellow.opacity(0.3)
            self.sunColor = Color("Sun", bundle: Bundle(for: BundleLocator.self))
        case 2.0 ..< 3.0:
            self.glowing = true
            self.glowColor = Color("Sun", bundle: Bundle(for: BundleLocator.self))
            self.sunColor = .orange
        case 3.0 ..< 500:
            self.glowing = true
            self.glowColor = .orange
            self.sunColor = .red
        default:
            self.glowing = false
            self.glowColor = .clear
            self.sunColor = Color("Sun_Zero", bundle: Bundle(for: BundleLocator.self))
        }
    }

    public var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .foregroundColor(sunColor)
                .frame(width: sunSize, height: sunSize)
                .glow(active: glowing, color: glowColor)

            ForEach(Array(stride(from: 0.0, to: .pi * 2, by: .pi / 4)), id: \.self) {
                RoundedRectangle(cornerRadius: 2.0)
                    .foregroundColor(sunColor)
                    .frame(width: sunSize * 0.39, height: sunSize * 0.17)
                    .offset(x: 0 - (sunSize * 0.86))
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
