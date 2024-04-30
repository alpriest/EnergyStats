//
//  ContentView.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 27/04/2024.
//

import Energy_Stats_Core
import SwiftUI

struct ContentView: View {
    @State private var batterySOC: Double?
    @State private var viewModel: ContentViewModel

    private enum Constants {
        static let iconWidth: CGFloat = 34.0
        static let iconHeight: CGFloat = 34.0
    }

    init(keychainStore: KeychainStoring, network: Networking, configManager: ConfigManaging) {
        self._viewModel = State(initialValue: ContentViewModel(keychainStore: keychainStore, network: network, configManager: configManager))
    }

    var body: some View {
        VStack {
            Grid {
                GridRow(alignment: .top) {
                    solarView()
                    Spacer()
                    homeView()
                }

                Spacer(minLength: 10)

                GridRow(alignment: .top) {
                    batteryView()
                    Spacer(minLength: 15)
                    gridView()
                }
            }.padding(.vertical)

            HStack {
                switch viewModel.loadState {
                case .inactive:
                    if let lastUpdated = viewModel.state?.lastUpdated {
                        Text(lastUpdated, format: .dateTime)
                            .foregroundStyle(Color.gray)
                    }
                case .active:
                    ProgressView()
                case .error:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.red)
                    Text("Failed to load")
                }
            }
            .font(.system(size: 10))
        }
        .task {
            await viewModel.loadData()
        }
        .padding()
    }

    func solarView() -> some View {
        VStack(alignment: .center) {
            if let solar = viewModel.state?.solar {
                SunView(solar: solar, sunSize: 18)
                    .frame(width: Constants.iconWidth, height: Constants.iconHeight)

                Text(solar.kWh(2))
                    .multilineTextAlignment(.center)
            } else {
                SunView(solar: 0)
                    .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                    .redacted(reason: .placeholder)

                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }

    func batteryView() -> some View {
        let color: Color
        if let state = viewModel.state {
            color = state.battery.tintColor
        } else {
            color = .iconDisabled
        }

        return VStack(alignment: .center) {
            Image(systemName: "minus.plus.batteryblock.fill")
                .font(.system(size: 36))
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(color)

            if let batterySOC = viewModel.state?.batterySOC, let battery = viewModel.state?.battery {
                Text(abs(battery).kWh(2))
                Text(batterySOC, format: .percent)
            } else {
                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }

    func homeView() -> some View {
        VStack(alignment: .center) {
            Image(systemName: "house.fill")
                .font(.system(size: 36))
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(Color.iconDisabled)

            if let house = viewModel.state?.house {
                Text(house.kW(2))
            } else {
                Text("xxxxx")
                    .redacted(reason: .placeholder)
            }
        }
    }

    func gridView() -> some View {
        let color: Color
        if let state = viewModel.state {
            color = state.grid.tintColor
        } else {
            color = .iconDisabled
        }

        return VStack(alignment: .center) {
            PylonView()
                .frame(width: Constants.iconWidth, height: Constants.iconHeight)
                .foregroundStyle(color)

            HStack {
                if let grid = viewModel.state?.grid {
                    Text(abs(grid).kWh(2))
                } else {
                    Text("xxxxx")
                        .redacted(reason: .placeholder)
                }
            }
        }
    }
}

extension Double? {
    var tintColor: Color {
        guard let self else { return Color.primary }

        if self < 0 {
            return .linesNegative
        } else if self > 0 {
            return .linesPositive
        } else {
            return .iconDisabled
        }
    }
}

#Preview {
    ContentView(keychainStore: PreviewKeychainStore(), network: DemoNetworking(), configManager: PreviewConfigManager())
}
