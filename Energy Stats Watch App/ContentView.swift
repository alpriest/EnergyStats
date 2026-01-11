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
    case lastUpdated = 5
}

struct ContentView: View {
    @State private var batterySOC: Double?
    @State private var viewModel: ContentViewModel
    let solarDefinitions: SolarRangeDefinitions
    @AppStorage("watchSelectedTabIndex") private var selectedTabIndex = Tab.grid

    init(network: Networking, config: WatchConfigManaging) {
        self._viewModel = State(initialValue: ContentViewModel(network: network, config: config))
        self.solarDefinitions = config.solarDefinitions
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .inactive:
                tabs
            case .active:
                ProgressView()
            case .error(_, let message):
                Text(message)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
        }
        .background(Color.white.opacity(0.05))
        .task(id: viewModel.deviceSN) { Task { await viewModel.loadData() }}
        .onReceive(NotificationCenter.default.publisher(for: WKApplication.didBecomeActiveNotification)) { _ in
            Task { await viewModel.loadData() }
        }
    }
    
    private var tabs: some View {
        TabView(selection: $selectedTabIndex) {
            allItems
                .tag(Tab.all)

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

            LastUpdatedView(lastUpdated: viewModel.state?.lastUpdated)
                .tag(Tab.lastUpdated)
        }
        .tabViewStyle(.page)
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
        .padding(.horizontal, 14)
    }
}

#Preview {
    ContentView(
        network: NetworkService.preview(),
        config: PreviewWatchConfig()
    )
}
