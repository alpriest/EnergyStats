//
//  SolarPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/03/2023.
//

import Combine
import SwiftUI

struct SolarPowerView: View {
    let appTheme: LatestAppTheme
    let solar: Double
    @State private var glowing = false
    @State private var glowColor: Color = .clear
    @State private var sunColor: Color = .yellow

    var body: some View {
        VStack {
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
            .frame(width: 40, height: 40)

            PowerFlowView(amount: solar, appTheme: appTheme, showColouredLines: false)
        }
        .onAppear {
            switch solar {
            case 1 ..< 2:
                glowing = false
                sunColor = .yellow
            case 2 ..< 3:
                glowing = true
                glowColor = .yellow
                sunColor = .orange
            case 3 ..< 500:
                glowing = true
                glowColor = .orange
                sunColor = .red
            default:
                glowing = false
                sunColor = .black
            }
        }
    }

    private var foregroundColor: Color {
        if solar > 0 {
            return Color.yellow
        } else {
            return Color.black
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
