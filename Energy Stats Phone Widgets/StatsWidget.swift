//
//  StatsWidget.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

// struct StatsWidget: Widget {
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: )
//    }
// }

struct StatsWidgetView: View {
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

                        // TODO:
                        //                        Button(intent: UpdateBatteryChargeLevelIntent()) {
                        //                            Text("Tap to retry")
                        //                        }.buttonStyle(.bordered)
                    }
                }
            } else {
                StatsGraphView(
                    gridImport: entry.gridImport,
                    gridExport: entry.gridExport,
                    home: entry.home,
                    batteryCharge: entry.batteryCharge,
                    batteryDischarge: entry.batteryDischarge,
                    lastUpdated: entry.date
//                    soc: Double(entry.soc ?? 0) / 100.0,
//                    chargeStatusDescription: entry.chargeStatusDescription,
//                    appSettings: configManager.appSettingsPublisher.value,
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
