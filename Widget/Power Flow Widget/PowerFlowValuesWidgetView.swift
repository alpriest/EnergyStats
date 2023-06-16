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
    let network: BackgroundNetwork

    init() {
        self.network = BackgroundNetwork()
    }

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            PowerFlowValuesWidgetView(entry: entry, configManager: network.configManager)
        }
    }
}

class BackgroundNetwork: NSObject, URLSessionDelegate {
    lazy var backgroundUrlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "WidgetBackgroundFetch")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    let configManager: ConfigManaging

    override init() {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let store = InMemoryLoggingNetworkStore()

        let network = NetworkFacade(network: Network(credentials: keychainStore, config: config, store: store),
                                    config: config)
        self.configManager = ConfigManager(networking: network, config: config)
    }

    func fetchRaw() async {
        let graphVariables = [configManager.variables.named("feedinPower"),
                              configManager.variables.named("gridConsumptionPower"),
                              configManager.variables.named("generationPower"),
                              configManager.variables.named("loadsPower"),
                              configManager.variables.named("batChargePower"),
                              configManager.variables.named("batDischargePower")].compactMap { $0 }

        backgroundUrlSession.downloadTask(with: <#T##URLRequest#>)
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
            entry: SimpleEntry.loaded(battery: 0.74, soc: 0.80, grid: 2.0, home: -0.321, solar: 3.20),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
