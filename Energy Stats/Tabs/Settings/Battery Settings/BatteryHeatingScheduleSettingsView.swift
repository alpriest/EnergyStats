//
//  BatteryHeatingScheduleSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/01/2026.
//

import Energy_Stats_Core
import StoreKit
import SwiftUI

struct BatteryHeatingScheduleSettingsView: View {
    @StateObject var viewModel: BatteryHeatingScheduleSettingsViewModel
    @Environment(\.requestReview) private var requestReview

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: BatteryHeatingScheduleSettingsViewModel(networking: networking, config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                if let currentState = viewModel.viewData.currentState {
                    Text(currentState)
                }
                BatteryHeatingTimePeriodView(
                    timePeriod: $viewModel.viewData.timePeriod1,
                    title: "Time period 1"
                )
                BatteryHeatingTimePeriodView(
                    timePeriod: $viewModel.viewData.timePeriod2,
                    title: "Time period 2"
                )
                BatteryHeatingTimePeriodView(
                    timePeriod: $viewModel.viewData.timePeriod3,
                    title: "Time period 3"
                )

                Section(
                    header: Text("Start temperature range"),
                    content: {
                        RangeSlider(
                            lower: $viewModel.viewData.minStartTemperature,
                            upper: $viewModel.viewData.maxStartTemperature,
                            bounds: -30 ... 30
                        )
                    }
                )
                
                Section(
                    header: Text("End temperature range"),
                    content: {
                        RangeSlider(
                            lower: $viewModel.viewData.minEndTemperature,
                            upper: $viewModel.viewData.maxEndTemperature,
                            bounds: -30 ... 30
                        )
                    }
                )
            }

            BottomButtonsView(dirty: viewModel.isDirty) {
                viewModel.save()
                requestReview()
            }
        }
        .navigationTitle(.batteryHeatingSchedule)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#if DEBUG
struct BatteryHeatingScheduleSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BatteryHeatingScheduleSettingsView(
                networking: NetworkService.preview(),
                config: ConfigManager.preview()
            )
        }
    }
}
#endif
