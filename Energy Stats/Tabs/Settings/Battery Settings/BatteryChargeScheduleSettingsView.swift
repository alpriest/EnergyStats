//
//  BatteryChargeScheduleSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Energy_Stats_Core
import SwiftUI

struct BatteryChargeScheduleSettingsView: View {
    @StateObject var viewModel: BatteryChargeScheduleSettingsViewModel
    @Environment(\.dismiss) var dismiss

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
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                })
            }

            BottomButtonsView { viewModel.save() }
        }
        .navigationTitle("Battery Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .loadable($viewModel.state, retry: { viewModel.load() })
        .onChange(of: viewModel.timePeriod1) { newValue in
            viewModel.generateSummary(period1: newValue, period2: viewModel.timePeriod2)
        }
        .onChange(of: viewModel.timePeriod2) { newValue in
            viewModel.generateSummary(period1: viewModel.timePeriod1, period2: newValue)
        }
        .alert(alertContent: $viewModel.alertContent)
        .onChange(of: viewModel.shouldDismiss) {
            if $0 {
                dismiss()
            }
        }
    }
}

struct BatteryForceChargeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BatteryChargeScheduleSettingsView(networking: DemoNetworking(),
                                           config: ConfigManager(networking: DemoNetworking(), config: MockConfig()))
        }
    }
}
