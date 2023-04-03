//
//  SolarPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/03/2023.
//

import Combine
import SwiftUI
import Energy_Stats_Core

struct SunView: View {
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

struct SolarPowerView: View {
    let appTheme: LatestAppTheme
    let solar: Double
    @State private var glowing = false
    @State private var glowColor: Color = .clear
    @State private var sunColor: Color = .yellow

    var body: some View {
        VStack {
            SunView(glowing: glowing, glowColor: glowColor, sunColor: sunColor)
                .frame(width: 40, height: 40)

            PowerFlowView(amount: solar, appTheme: appTheme, showColouredLines: false)
        }
        .onAppear {
            switch solar {
            case 1 ..< 2:
                glowing = false
                sunColor = Color("Sun")
            case 2 ..< 3:
                glowing = true
                glowColor = Color("Sun")
                sunColor = .orange
            case 3 ..< 500:
                glowing = true
                glowColor = .orange
                sunColor = .red
            default:
                glowing = false
                sunColor = Color("Sun_Zero")
            }
        }
    }
}

struct SolarPowerView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            SolarPowerView(
                appTheme: CurrentValueSubject(AppTheme.mock()),
                solar: 0
            )
            SolarPowerView(
                appTheme: CurrentValueSubject(AppTheme.mock()),
                solar: 0.5
            )
            SolarPowerView(
                appTheme: CurrentValueSubject(AppTheme.mock()),
                solar: 1.5
            )
            SolarPowerView(
                appTheme: CurrentValueSubject(AppTheme.mock()),
                solar: 2.5
            )
            SolarPowerView(
                appTheme: CurrentValueSubject(AppTheme.mock()),
                solar: 3.5
            )
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
