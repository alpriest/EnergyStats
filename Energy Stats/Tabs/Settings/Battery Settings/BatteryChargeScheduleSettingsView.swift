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
                BatteryTimePeriodView(timePeriod: $viewModel.timePeriod1, title: "Time period 1")
                BatteryTimePeriodView(timePeriod: $viewModel.timePeriod2, title: "Time period 2")

                Section(content: {}, footer: {
                    VStack(alignment: .leading) {
                        Text("Schedule summary")
                            .font(.headline)

                        Text(viewModel.summary)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                        Text("about_59_seconds")
                            .padding(.top)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                })
            }

            BottomButtonsView {
                viewModel.save()
                requestReview()
            }
        }
        .navigationTitle(.batterySchedule)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
        .onChange(of: viewModel.timePeriod1) { newValue in
            viewModel.generateSummary(period1: newValue, period2: viewModel.timePeriod2)
        }
        .onChange(of: viewModel.timePeriod2) { newValue in
            viewModel.generateSummary(period1: viewModel.timePeriod1, period2: newValue)
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
