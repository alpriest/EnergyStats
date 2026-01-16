//
//  BatteryWidget.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftData
import SwiftUI
import WidgetKit

struct BatteryWidget: Widget {
    private let kind: String = "BatteryWidget"
    private let configManager: ConfigManaging
    private let keychainStore: KeychainStoring

    init() {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkService.standard(keychainStore: keychainStore,
                                              urlSession: URLSession.shared,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
        let appSettingsStore = AppSettingsStoreFactory.make()
        configManager = ConfigManager(networking: network, config: config, appSettingsStore: appSettingsStore, keychainStore: keychainStore)
        self.keychainStore = keychainStore
        AppSettingsStoreFactory.update(from: configManager)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryTimelineProvider(config: HomeEnergyStateManagerConfigAdapter(config: configManager))) { entry in
            BatteryWidgetView(entry: entry, configManager: configManager)
                .modelContainer(HomeEnergyStateManager.shared.modelContainer)
        }
        .configurationDisplayName("Battery Status Widget")
        .description("Shows the status of your battery storage")
        .supportedFamilies([.accessoryCircular,
                            .accessoryInline,
                            .systemSmall,
                            .systemMedium])
    }
}

struct BatteryWidgetView: View {
    var entry: BatteryTimelineProvider.Entry
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

                        Button(intent: UpdateStatsIntent()) {
                            Text("Tap to retry")
                        }.buttonStyle(.bordered)
                    }
                }
            } else if case .syncRequired = entry.state {
                SyncRequiredView()
            } else {
                BatteryStatusView(
                    soc: Double(entry.soc ?? 0) / 100.0,
                    chargeStatusDescription: entry.chargeStatusDescription,
                    appSettings: configManager.currentAppSettings,
                    hasError: entry.errorMessage != nil
                )
            }
        }
        .containerBackground(for: .widget) {
            switch entry.state {
            case .failedWithoutData, .syncRequired:
                Color.clear
            default:
                GradientContainerBackground(date: entry.date)
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

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        BatteryWidgetView(
            entry: BatteryTimelineEntry.failed(error: "Something went wrong"),
            configManager: ConfigManager(
                networking: NetworkService.preview(),
                config: MockConfig(),
                appSettingsStore: AppSettingsStoreFactory.make(),
                keychainStore: KeychainStore.preview()
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))

        BatteryWidgetView(
            entry: BatteryTimelineEntry.loaded(date: Date(),
                                               soc: 50,
                                               chargeStatusDescription: "Full in 22 minutes",
                                               errorMessage: "Could not refresh",
                                               batteryPower: 0),
            configManager: ConfigManager.preview()
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
