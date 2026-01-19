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
                    Section(header: Text("Curerent heater state")) {
                        Text(currentState)
                    }
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
                    header: Text("Temperatures"),
                ) {
                    RangeSlider(
                        lower: $viewModel.viewData.startTemperature,
                        upper: $viewModel.viewData.endTemperature,
                        lowerBounds: viewModel.viewData.minStartTemperature ... viewModel.viewData.maxStartTemperature,
                        upperBounds: viewModel.viewData.minEndTemperature ... viewModel.viewData.maxEndTemperature
                    )
                }

                Section(content: {}, footer: {
                    VStack(alignment: .leading) {
                        Text("Schedule summary")
                            .font(.headline)

                        Text(viewModel.viewData.summary)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                })
            }

            BottomButtonsView(dirty: viewModel.isDirty) {
                viewModel.save()
                requestReview()
            }
        }
        .onChange(of: viewModel.viewData.timePeriod1) { _ in
            viewModel.updateSummary()
        }
        .onChange(of: viewModel.viewData.timePeriod2) { _ in
            viewModel.updateSummary()
        }
        .onChange(of: viewModel.viewData.timePeriod3) { _ in
            viewModel.updateSummary()
        }
        .onChange(of: viewModel.viewData.startTemperature) { _ in
            viewModel.updateSummary()
        }
        .onChange(of: viewModel.viewData.endTemperature) { _ in
            viewModel.updateSummary()
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
