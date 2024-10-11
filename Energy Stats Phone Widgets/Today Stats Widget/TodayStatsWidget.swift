//
//  TodayStatsWidget.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct TodayStatsWidget: Widget {
    private let kind: String = "TodayStatsWidget"
    private let configManager: ConfigManaging

    init() {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkService.standard(keychainStore: keychainStore,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsTimelineProvider(config: HomeEnergyStateManagerConfigAdapter(config: configManager))) { entry in
            TodayStatsWidgetView(entry: entry, configManager: configManager)
        }
        .configurationDisplayName("Today Stats Widget")
        .description("Shows the stats of your installation for the day.")
        .supportedFamilies([.systemMedium])
    }
}

struct TodayStatsWidgetView: View {
    var entry: StatsTimelineProvider.Entry
    let configManager: ConfigManaging
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if case let .failedWithoutData(reason) = entry.state {
                switch family {
                case .accessoryCircular:
                    VStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)

                        Text("No device")
                            .font(.system(size: 8))
                    }.padding(.bottom)
                default:
                    VStack {
                        HStack(alignment: .center) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.red)
                                .font(.title)

                            Text(reason)
                        }.padding(.bottom)

                        Button(intent: UpdateTodayStatsIntent()) {
                            Text("Tap to retry")
                        }.buttonStyle(.bordered)
                    }
                }
            } else {
                StatsWidgetGraphView(
                    home: entry.home,
                    gridImport: entry.gridImport,
                    gridExport: entry.gridExport,
                    batteryCharge: entry.batteryCharge,
                    batteryDischarge: entry.batteryDischarge,
                    lastUpdated: entry.date
//                    hasError: entry.errorMessage != nil
                )
            }
        }
        .redacted(reason: entry.state == .placeholder ? [.placeholder] : [])
        .containerBackground(for: .widget) {
            switch entry.state {
            case .failedWithoutData:
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
                        Color.paleGray.opacity(0.6)
                            .frame(height: footerHeight)
                    }
                }
            }
        }
        .modelContainer(for: StatsWidgetState.self)
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
