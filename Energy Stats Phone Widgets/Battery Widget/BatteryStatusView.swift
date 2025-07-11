//
//  BatteryStatusView.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct BatteryStatusView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.redactionReasons) var redactionReasons
    let soc: Double
    let chargeStatusDescription: String?
    let appSettings: AppSettings
    let hasError: Bool

    var body: some View {
        switch self.family {
        case .systemSmall:
            ZStack(alignment: .bottom) {
                VStack(alignment: .center) {
                    gaugeView()

                    descriptionView()
                        .font(.caption)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }

                HStack {
                    if hasError {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.red)
                    }
                }
                .font(.system(size: 8.0, weight: .light))
            }
        case .accessoryInline:
            HStack {
                Image(systemName: "minus.plus.batteryblock.fill")
                descriptionView()
            }
        case .accessoryCircular:
            gaugeView(scale: false)
        default:
            VStack {
                HStack(spacing: 44) {
                    gaugeView()
                        .padding(.leading)
                        .padding(.top)

                    descriptionView()
                        .font(.title)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }

                Group {
                    Spacer()

                    HStack {
                        if hasError {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.red)

                            Text("Update failed")
                        }
                    }
                    .font(.system(size: 12.0, weight: .light))
                }
            }.padding(.top, 12)
        }
    }

    private func gaugeView(scale: Bool = true) -> some View {
        Button(intent: UpdateStatsIntent()) {
            VStack {
                Gauge(value: soc) {
                    Image(systemName: "minus.plus.batteryblock.fill")
                        .font(.system(size: 16))
                } currentValueLabel: {
                    Text(soc, format: .percent)
                        .font(.system(size: 26))
                }
                .gaugeStyle(.accessoryCircular)
                .padding(.bottom, 4)
                .tint(tint)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(scale ? (family == .systemSmall ? 1.2 : 1.4) : 1.0)
    }

    private func descriptionView() -> some View {
        OptionalView(chargeStatusDescription) {
            Text($0)
                .multilineTextAlignment(.center)
        }
    }

    private var tint: Color {
        guard redactionReasons.isEmpty else { return Color(uiColor: .label) }

        if soc < 0.40 {
            return .red
        } else if soc < 0.70 {
            return .orange
        } else {
            return .green
        }
    }
}

struct BatteryStatusView_Previews: PreviewProvider {
    static var mylightGray: Color { Color("pale_gray", bundle: Bundle(for: CountdownTimer.self)) }

    static var previews: some View {
        BatteryStatusView(
            soc: 0.8,
            chargeStatusDescription: "Full in 22 minutes",
            appSettings: .mock(),
            hasError: false
        )
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        .containerBackground(for: .widget) {
            VStack {
                Color.clear
                mylightGray.opacity(0.6)
                    .frame(height: 38)
            }
        }
    }
}
