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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if case let .failed(reason) = entry.state {
                VStack {
                    HStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.red)
                            .font(.title)

                        Text(reason)
                    }.padding(.bottom)

                    Button(intent: UpdateBatteryChargeLevelIntent()) {
                        Text("Tap to retry")
                    }.buttonStyle(.bordered)
                }
            } else {
                BatteryStatusView(
                    soc: Double(entry.soc) / 100.0,
                    chargeStatusDescription: entry.chargeStatusDescription,
                    lastUpdated: entry.date,
                    appTheme: configManager.appTheme.value
                ).redacted(reason: entry.state == .placeholder ? [.placeholder] : [])
            }
        }
        .containerBackground(for: .widget) {
            switch entry.state {
            case .failed:
                Color.clear
            default:
                if colorScheme == .dark {
                    VStack {
                        Color.clear
                        Color.white.opacity(0.2)
                            .frame(height: footerHeight)
                    }
                } else {
                    VStack {
                        Color.clear
                        Color.lightGray.opacity(0.6)
                            .frame(height: footerHeight)
                    }
                }
            }
        }
        .modelContainer(for: BatteryWidgetState.self)
    }

    var footerHeight: CGFloat {
        switch family {
        case .systemSmall:
            return 32
        default:
            return 38
        }
    }
}

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        BatteryWidgetView(
            entry: SimpleEntry.failed(error: "Something went wrong"),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))

        BatteryWidgetView(
            entry: SimpleEntry.loaded(soc: 50, chargeStatusDescription: "Full in 22 minutes"),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
