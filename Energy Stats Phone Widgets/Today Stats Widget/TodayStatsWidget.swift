//
//  TodayStatsWidget.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Energy_Stats_Core
import SwiftData
import SwiftUI
import WidgetKit

struct TodayStatsWidget: Widget {
    private let kind: String = "TodayStatsWidget"
    private let configManager: ConfigManaging
    private let keychainStore: KeychainStoring
    private var container: ModelContainer

    init() {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkService.standard(keychainStore: keychainStore,
                                              urlSession: URLSession.shared,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
        let appSettingsPublisher = AppSettingsPublisherFactory.make()
        configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
        self.keychainStore = keychainStore
        AppSettingsPublisherFactory.update(from: configManager)
        container = try! ModelContainer(for: BatteryWidgetState.self, StatsWidgetState.self)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsTimelineProvider(config: HomeEnergyStateManagerConfigAdapter(config: configManager, keychainStore: keychainStore))) { entry in
            TodayStatsWidgetView(entry: entry, configManager: configManager)
                .modelContainer(container)
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
            } else if case .syncRequired = entry.state {
                SyncRequiredView()
            } else {
                StatsWidgetGraphView(
                    home: entry.home,
                    gridImport: entry.gridImport,
                    gridExport: entry.gridExport,
                    batteryCharge: entry.batteryCharge,
                    batteryDischarge: entry.batteryDischarge,
                    totalHome: entry.totalHome,
                    totalGridImport: entry.totalGridImport,
                    totalGridExport: entry.totalGridExport,
                    totalBatteryCharge: entry.totalBatteryCharge,
                    totalBatteryDischarge: entry.totalBatteryDischarge,
                    lastUpdated: entry.date
                )
            }
        }
        .redacted(reason: entry.state == .placeholder ? [.placeholder] : [])
        .containerBackground(for: .widget) {
            switch entry.state {
            case .failedWithoutData, .syncRequired:
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
