//
//  SolarPowerView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/03/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SolarPowerViewModel {
    let solar: Double
    let generation: Double
}

struct SolarPowerView: View {
    private let appTheme: AppTheme
    private let viewModel: SolarPowerViewModel

    init(appTheme: AppTheme, viewModel: SolarPowerViewModel) {
        self.appTheme = appTheme
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if appTheme.showTotalYield {
                Text("Yield today ") + Text(appTheme.showInW ? viewModel.generation.wh() : viewModel.generation.kWh(appTheme.decimalPlaces))
            }

            switch viewModel.solar {
            case 1 ..< 2:
                SunView(solar: viewModel.solar, glowing: false, glowColor: .clear, sunColor: Color("Sun"))
                    .frame(width: 40, height: 40)
            case 2 ..< 3:
                SunView(solar: viewModel.solar, glowing: true, glowColor: Color("Sun"), sunColor: .orange)
                    .frame(width: 40, height: 40)
            case 3 ..< 500:
                SunView(solar: viewModel.solar, glowing: true, glowColor: .orange, sunColor: .red)
                    .frame(width: 40, height: 40)
            default:
                SunView(solar: viewModel.solar, glowing: false, glowColor: .clear, sunColor: Color("Sun_Zero"))
                    .frame(width: 40, height: 40)
            }

            PowerFlowView(amount: viewModel.solar, appTheme: appTheme, showColouredLines: false)
        }
    }
}

struct SolarPowerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AdjustableView(config: MockConfig())

            HStack {
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 0, generation: 0)
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 0.5, generation: 1.5)
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 1.5, generation: 1.5)
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 2.5, generation: 4.5)
                )
                SolarPowerView(
                    appTheme: AppTheme.mock(),
                    viewModel: SolarPowerViewModel(solar: 3.5, generation: 9.5)
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
                    SolarPowerView(appTheme: AppTheme.mock(), viewModel: SolarPowerViewModel(solar: amount, generation: 8.5))
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
