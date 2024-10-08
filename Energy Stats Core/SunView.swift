//
//  SunView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/05/2023.
//

import SwiftUI

public struct SunView: View {
    private let solar: Double
    private let glowing: Bool
    private let glowColor: Color
    private let sunColor: Color
    private let sunSize: CGFloat

    public init(solar: Double, solarDefinitions: SolarRangeDefinitions, sunSize: CGFloat = 23) {
        self.solar = solar
        self.sunSize = sunSize

        switch solar {
        case 0.001 ..< solarDefinitions.breakPoint1:
            self.glowing = false
            self.glowColor = .clear
            self.sunColor = Color("Sun", bundle: Bundle(for: BundleLocator.self))
        case solarDefinitions.breakPoint1 ..< solarDefinitions.breakPoint2:
            self.glowing = true
            self.glowColor = .yellow.opacity(0.3)
            self.sunColor = Color("Sun", bundle: Bundle(for: BundleLocator.self))
        case solarDefinitions.breakPoint2 ..< solarDefinitions.breakPoint3:
            self.glowing = true
            self.glowColor = Color("Sun", bundle: Bundle(for: BundleLocator.self))
            self.sunColor = .orange
        case solarDefinitions.breakPoint3 ..< 500:
            self.glowing = true
            self.glowColor = .orange
            self.sunColor = .red
        default:
            self.glowing = false
            self.glowColor = .clear
            self.sunColor = .iconDisabled
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
