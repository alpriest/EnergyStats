//
//  PowerFlowValuesWidgetView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct PowerFlowValuesWidget: Widget {
    let kind: String = "PowerFlowValuesWidget"
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
            PowerFlowValuesWidgetView(entry: entry, configManager: configManager)
        }
    }
}

struct PowerFlowValuesWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    let configManager: ConfigManaging

    var body: some View {
        switch self.family {
        case .systemSmall:
            SmallPowerFlowValuesWidgetView(entry: self.entry, configManager: self.configManager)
        default:
            LargePowerFlowValuesWidgetView(entry: self.entry, configManager: self.configManager)
        }
    }
}

struct PowerFlowValuesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PowerFlowValuesWidgetView(
            entry: SimpleEntry(date: Date(), soc: 0.80, grid: 2.0, home: -0.321, solar: 3.22, configuration: ConfigurationIntent()),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
