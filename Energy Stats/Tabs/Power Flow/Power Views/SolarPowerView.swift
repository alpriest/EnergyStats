//
//  SolarPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/03/2023.
//

import Combine
import Energy_Stats_Core
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

struct SolarPowerView: View {
    let appTheme: LatestAppTheme
    let solar: Double

    init(appTheme: LatestAppTheme, solar: Double) {
        self.appTheme = appTheme
        self.solar = solar
    }

    var body: some View {
        VStack {
            switch solar {
            case 1 ..< 2:
                SunView(solar: solar, glowing: false, glowColor: .clear, sunColor: Color("Sun"))
                    .frame(width: 40, height: 40)
            case 2 ..< 3:
                SunView(solar: solar, glowing: true, glowColor: Color("Sun"), sunColor: .orange)
                    .frame(width: 40, height: 40)
            case 3 ..< 500:
                SunView(solar: solar, glowing: true, glowColor: .orange, sunColor: .red)
                    .frame(width: 40, height: 40)
            default:
                SunView(solar: solar, glowing: false, glowColor: .clear, sunColor: Color("Sun_Zero"))
                    .frame(width: 40, height: 40)
            }

            PowerFlowView(amount: solar, appTheme: appTheme, showColouredLines: false)
        }
    }
}

struct SolarPowerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AdjustableView(config: MockConfig())

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

    struct AdjustableView: View {
        @State private var amount: Double = 3.0
        @State private var visible = true
        let config: Config

        var body: some View {
            VStack {
                Color.clear.overlay(
                    SolarPowerView(appTheme: CurrentValueSubject(AppTheme.mock()), solar: amount)
                ).frame(height: 100)

                Slider(value: $amount, in: 0 ... 5.0, step: 0.1, label: {
                    Text("kWH")
                }, onEditingChanged: { _ in
                    visible.toggle()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        visible.toggle()
                    }
                })

                Text(amount, format: .number)
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
