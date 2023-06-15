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
        let network = NetworkFacade(network: Network(credentials: keychainStore, config: config, store: store),
                                    config: config)
        configManager = ConfigManager(networking: network, config: config)
    }

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
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
            soc: entry.soc,
            battery: entry.battery,
            appTheme: configManager.appTheme.value
        )
        .scaleEffect(x: family == .systemLarge ? 2.5 : 1.0,
                     y: family == .systemLarge ? 2.5 : 1.0)
    }
}

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        BatteryWidgetView(
            entry: SimpleEntry(date: Date(), soc: 0.80, grid: 2.0, home: -0.321, solar: 3.22, configuration: ConfigurationIntent()),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
