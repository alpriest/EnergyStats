//
//  LargePowerFlowValuesWidgetView.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct FlowData: Hashable, Identifiable, Equatable {
    let id = UUID()
    let image: () -> AnyView
    let amount: Double
    let showColouredLines: Bool

    static func ==(lhs: FlowData, rhs: FlowData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(amount)
        hasher.combine(showColouredLines)
    }
}

struct LargePowerFlowValuesWidgetView: View {
    let entry: Provider.Entry
    let configManager: ConfigManaging
    let data: [FlowData]

    init(entry: Provider.Entry, configManager: ConfigManaging) {
        self.entry = entry
        self.configManager = configManager

        data = [
            FlowData(
                image: { AnyView(Image(systemName: "sun.max.fill")) },
                amount: entry.solar,
                showColouredLines: false
            ),
            FlowData(
                image: { AnyView(Image(systemName: "house.fill")) },
                amount: entry.home,
                showColouredLines: false
            ),
            FlowData(
                image: { AnyView(PylonView(lineWidth: 1)) },
                amount: entry.grid,
                showColouredLines: true
            )
        ]
    }

    var body: some View {
        HStack {
            BatteryStatusView(
                soc: entry.soc,
                battery: entry.battery,
                appTheme: configManager.appTheme.value
            )
            .frame(maxWidth: .infinity)

            VStack {
                LazyVGrid(columns: [GridItem(.fixed(40)), GridItem(.fixed(90), alignment: .trailing)]) {
                    ForEach(data, id: \.self) { item in
                        item.image()
                            .font(.system(size: 20))
                            .frame(width: 22, height: 22)
                            .padding(.horizontal, 4)

                        EnergyAmountView(
                            amount: item.amount,
                            decimalPlaces: configManager.appTheme.value.decimalPlaces,
                            backgroundColor: configManager.appTheme.value.lineColor(for: item.amount, showColour: item.showColouredLines),
                            textColor: configManager.appTheme.value.textColor(for: item.amount, showColour: item.showColouredLines),
                            appTheme: configManager.appTheme.value
                        )
                        .monospacedDigit()
                        .frame(minWidth: 110, alignment: .trailing)
                        .font(.system(size: 18))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing)
        }
    }
}

struct LargePowerFlowValuesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        LargePowerFlowValuesWidgetView(
            entry: SimpleEntry(date: Date(), soc: 0.80, grid: 2.0, home: -0.321, solar: 3.22, configuration: ConfigurationIntent()),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
