//
//  GenerationStatsWidget.swift
//  Energy Stats
//
//  Created by Alistair Priest on 10/07/2025.
//

import Energy_Stats_Core
import SwiftData
import SwiftUI
import WidgetKit

struct GenerationStatsWidget: Widget {
    private let kind: String = "GenerationStatsWidget"
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
        container = try! ModelContainer(for: GenerationStatsWidgetState.self)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GenerationStatsTimelineProvider(config: HomeEnergyStateManagerConfigAdapter(config: configManager, keychainStore: keychainStore))) { entry in
            GenerationStatsWidgetView(entry: entry, configManager: configManager)
                .modelContainer(container)
        }
        .configurationDisplayName("Generation Stats Widget")
        .description("Shows the generation stats of your installation.")
        .supportedFamilies([.systemMedium])
    }
}

struct GenerationStatsWidgetView: View {
    var entry: GenerationStatsTimelineProvider.Entry
    let configManager: ConfigManaging
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if case let .failedWithoutData(reason) = entry.state {
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
            } else if case .syncRequired = entry.state {
                SyncRequiredView()
            } else {
                Text("values here")
            }
        }
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

        var footerHeight: CGFloat {
            switch family {
            case .systemSmall:
                return 32
            default:
                return 38
            }
        }
    }
}
