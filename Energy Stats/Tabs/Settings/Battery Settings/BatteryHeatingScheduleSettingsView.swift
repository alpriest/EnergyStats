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
        Group {
            switch viewModel.viewData.available {
            case true:
                scheduleAvailable()
                    .navigationTitle(.batteryHeatingSchedule)
            case false:
                Text("Battery heating is not available")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
        .alert(alertContent: $viewModel.alertContent)
    }

    private func scheduleAvailable() -> some View {
        VStack(spacing: 0) {
            Form {
                Section(
                    header: Text("Schedule summary")
                ) {
                    Text(viewModel.viewData.summary)
                        .transition(.opacity)
                }

                Toggle(isOn: $viewModel.viewData.enabled.animation()) {
                    Text("Heating schedule enabled")
                }

                if let currentState = viewModel.viewData.currentState {
                    Section(header: Text("Current heater state")) {
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
                    footer: Text("Minimum and maximum temperature ranges are controlled by your inverter firmware.")
                ) {
                    RangeSlider(
                        lower: $viewModel.viewData.startTemperature,
                        upper: $viewModel.viewData.endTemperature,
                        lowerBounds: viewModel.viewData.minStartTemperature ... viewModel.viewData.maxStartTemperature,
                        upperBounds: viewModel.viewData.minEndTemperature ... viewModel.viewData.maxEndTemperature
                    )
                }

                Section(footer: Text("Solar generation can be used for heating. If the SoC is above 40% the battery can be used for heating. If the SoC is below 40%, the grid is used for heating. When the battery is being used for heating, it can discharge but won't charge. When grid or solar is being used for heating, the battery won't charge or discharge."))
                    {}
            }

            BottomButtonsView(dirty: viewModel.isDirty) {
                viewModel.save()
                requestReview()
            }
        }
        .onChange(of: viewModel.viewData.enabled) { _ in
            viewModel.updateSummary()
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
