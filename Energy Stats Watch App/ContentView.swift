//
//  ContentView.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 27/04/2024.
//

import Energy_Stats_Core
import SwiftUI

enum Constants {
    static let iconWidth: CGFloat = 34.0
    static let iconHeight: CGFloat = 34.0
}

struct ContentView: View {
    @State private var batterySOC: Double?
    @State private var viewModel: ContentViewModel
    @State private var alertContent: AlertContent?

    init(keychainStore: KeychainStoring, network: Networking, config: WatchConfigManaging) {
        self._viewModel = State(initialValue: ContentViewModel(keychainStore: keychainStore, network: network, config: config))
    }

    var body: some View {
        VStack {
            Grid {
                GridRow(alignment: .top) {
                    SolarPowerView(value: viewModel.state?.solar)
                    Spacer()
                    HomePowerView(value: viewModel.state?.house)
                }

                Spacer(minLength: 10)

                GridRow(alignment: .top) {
                    BatteryPowerView(batterySOC: viewModel.state?.batterySOC, battery: viewModel.state?.battery)
                    Spacer(minLength: 15)
                    GridPowerView(value: viewModel.state?.grid, totalExport: viewModel.state?.totalExport)
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
                case .error(_, let message):
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.red)
                    Text("Failed to load - tap for more")
                        .onTapGesture {
                            alertContent = AlertContent(title: "Oops", message: LocalizedStringKey(stringLiteral: message))
                        }
                }
            }
            .font(.system(size: 10))
        }
        .alert(alertContent: $alertContent)
        .onReceive(NotificationCenter.default.publisher(for: WKApplication.didBecomeActiveNotification)) { _ in
            Task { await viewModel.loadData() }
        }
        .padding()
    }
}

#Preview {
    ContentView(
        keychainStore: KeychainStore.preview(),
        network: NetworkService.preview(),
        config: PreviewWatchConfig()
    )
}
