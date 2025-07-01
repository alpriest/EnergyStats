//
//  ContentView.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 27/04/2024.
//

import Energy_Stats_Core
import SwiftUI

enum Tab: Int, RawRepresentable {
    case all = 0
    case solar = 1
    case home = 2
    case battery = 3
    case grid = 4
}

struct ContentView: View {
    @State private var batterySOC: Double?
    @State private var viewModel: ContentViewModel
    @State private var alertContent: AlertContent?
    let solarDefinitions: SolarRangeDefinitions
    @AppStorage("watchSelectedTabIndex") private var selectedTabIndex = Tab.grid

    init(keychainStore: KeychainStoring, network: Networking, config: WatchConfigManaging) {
        self._viewModel = State(initialValue: ContentViewModel(keychainStore: keychainStore, network: network, config: config))
        self.solarDefinitions = config.solarDefinitions
    }

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            VStack {
                allItems
                footer
            }
            .tag(Tab.all)
            .padding(.horizontal)

            SolarPowerView(
                value: viewModel.state?.solar,
                solarDefinitions: solarDefinitions,
                iconScale: .large
            )
            .tag(Tab.solar)

            HomePowerView(
                value: viewModel.state?.house,
                iconScale: .large
            )
            .tag(Tab.home)

            BatteryPowerView(
                batterySOC: viewModel.state?.batterySOC,
                battery: viewModel.state?.battery,
                iconScale: .large
            )
            .tag(Tab.battery)

            GridPowerView(
                value: viewModel.state?.grid,
                totalExport: viewModel.state?.totalExport,
                totalImport: viewModel.state?.totalImport,
                iconScale: .large
            )
            .tag(Tab.grid)
        }
        .overlay(loadingOverlay)
        .tabViewStyle(.page)
        .background(Color.white.opacity(0.05))
        .alert(alertContent: $alertContent)
        .onReceive(NotificationCenter.default.publisher(for: WKApplication.didBecomeActiveNotification)) { _ in
            Task { await viewModel.loadData() }
        }
    }

    @ViewBuilder
    private var allItems: some View {
        Grid {
            GridRow(alignment: .top) {
                SolarPowerView(value: viewModel.state?.solar, solarDefinitions: solarDefinitions, iconScale: .small)
                Spacer()
                HomePowerView(value: viewModel.state?.house, iconScale: .small)
            }

            Spacer(minLength: 10)

            GridRow(alignment: .top) {
                BatteryPowerView(batterySOC: viewModel.state?.batterySOC, battery: viewModel.state?.battery, iconScale: .small)
                Spacer(minLength: 15)
                GridPowerView(value: viewModel.state?.grid, totalExport: viewModel.state?.totalExport, totalImport: viewModel.state?.totalImport, iconScale: .small)
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            switch viewModel.loadState {
            case .inactive:
                if let lastUpdated = viewModel.state?.lastUpdated {
                    Text(lastUpdated, format: .dateTime)
                        .foregroundStyle(Color.gray)
                }
            default:
                EmptyView()
            }
        }
        .font(.system(size: 10))
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        VStack {
            switch viewModel.loadState {
            case .inactive:
                EmptyView()
            case .active:
                ProgressView()
            case .error(_, let message):
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.red)
                    Text("Failed to load - tap for more")
                        .onTapGesture {
                            alertContent = AlertContent(title: "Oops", message: LocalizedStringKey(stringLiteral: message))
                        }
                }
                .padding()
                .border(Color.white.opacity(0.2), width: 0.5)
                .background(Color.black.opacity(0.8))
            }
        }
    }
}

#Preview {
    ContentView(
        keychainStore: KeychainStore.preview(),
        network: NetworkService.preview(),
        config: PreviewWatchConfig()
    )
}
