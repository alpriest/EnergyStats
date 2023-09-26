//
//  BatteryWidget.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct BatteryWidget: Widget {
    let kind: String = "BatteryWidget"
    let configManager: ConfigManaging

    init() {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let store = InMemoryLoggingNetworkStore()
        let network = NetworkFacade(network: Network(credentials: keychainStore, store: store),
                                    config: config,
                                    store: keychainStore)
        configManager = ConfigManager(networking: network, config: config)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BatteryWidgetView(entry: entry, configManager: configManager)
        }
    }
}

struct BatteryWidgetView: View {
    var entry: Provider.Entry
    let configManager: ConfigManaging
    @Environment(\.widgetFamily) var family

    var body: some View {
        BatteryStatusView(
            soc: Double(entry.soc) / 100.0,
            chargeStatusDescription: entry.chargeStatusDescription,
            lastUpdated: entry.date,
            appTheme: configManager.appTheme.value
        )
        .containerBackground(Color.white.opacity(0.1), for: .widget)
        .modelContainer(for: BatteryWidgetState.self)
    }
}

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        BatteryWidgetView(
            entry: SimpleEntry.loaded(soc: 80, chargeStatusDescription: "Full in 23 minutes"),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
