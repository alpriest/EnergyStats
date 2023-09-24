//
//  SmallWidget.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct SmallPowerFlowValuesWidgetView: View {
    let entry: Provider.Entry
    let configManager: ConfigManaging

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VerticalFlowGauge(
                        image: {
                            Image(systemName: "sun.max.fill")
                        },
                        amount: entry.solar,
                        showColouredLines: false,
                        appTheme: configManager.appTheme.value
                    )

                    VerticalFlowGauge(
                        image: {
                            Image(systemName: "minus.plus.batteryblock.fill")
                        },
                        amount: entry.soc,
                        showColouredLines: true,
                        appTheme: configManager.appTheme.value
                    )
                }.padding(.bottom, 8)

                HStack {
                    VerticalFlowGauge(
                        image: {
                            Image(systemName: "house.fill")
                        },
                        amount: entry.home,
                        showColouredLines: false,
                        appTheme: configManager.appTheme.value
                    )

                    VerticalFlowGauge(
                        image: {
                            PylonView(lineWidth: 1.4)
                        },
                        amount: entry.grid,
                        showColouredLines: true,
                        appTheme: configManager.appTheme.value
                    )
                }
            }

            Image(systemName: "plus")
                .font(.system(size: 128, weight: .ultraLight))
                .foregroundColor(Color(uiColor: .tertiarySystemFill))
        }
    }
}

struct SmallPowerFlowValuesWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallPowerFlowValuesWidgetView(
            entry: SimpleEntry.loaded(battery: 0.74, soc: 0.80, grid: 2.0, home: -0.321, solar: 3.20),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
