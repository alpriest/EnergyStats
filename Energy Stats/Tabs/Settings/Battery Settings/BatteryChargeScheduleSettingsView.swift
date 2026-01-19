//
//  BatteryChargeScheduleSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI
import StoreKit

struct BatteryChargeScheduleSettingsView: View {
    @StateObject var viewModel: BatteryChargeScheduleSettingsViewModel
    @Environment(\.requestReview) private var requestReview

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: BatteryChargeScheduleSettingsViewModel(networking: networking, config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                BatteryChargeTimePeriodView(timePeriod: $viewModel.viewData.timePeriod1, title: "Time period 1")
                BatteryChargeTimePeriodView(timePeriod: $viewModel.viewData.timePeriod2, title: "Time period 2")

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
        .navigationTitle(.batteryChargeSchedule)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
        .onChange(of: viewModel.viewData.timePeriod1) { newValue in
            viewModel.updateSummary(period1: newValue, period2: viewModel.viewData.timePeriod2)
        }
        .onChange(of: viewModel.viewData.timePeriod2) { newValue in
            viewModel.updateSummary(period1: viewModel.viewData.timePeriod1, period2: newValue)
        }
        .alert(alertContent: $viewModel.alertContent)
    }
}

#if DEBUG
struct BatteryForceChargeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BatteryChargeScheduleSettingsView(
                networking: NetworkService.preview(),
                config: ConfigManager.preview()
            )
        }
    }
}
#endif
