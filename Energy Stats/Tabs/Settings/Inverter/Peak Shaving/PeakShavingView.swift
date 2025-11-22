//
//  PeakShavingView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 25/05/2025.
//

import Energy_Stats_Core
import SwiftUI

struct PeakShavingView: View {
    @StateObject var viewModel: PeakShavingViewModel

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: PeakShavingViewModel(networking: networking, config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                if viewModel.viewData.supported {
                    Section {
                        VStack {
                            HStack {
                                Text("Import limit")
                                Spacer()
                                NumberTextField("Import limit", text: $viewModel.viewData.importLimit)
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                                Text("kW")
                                    .frame(width: 30)
                            }

                            HStack {
                                Text("Battery threshold SOC")
                                Spacer()
                                NumberTextField("Battery threshold SOC", text: $viewModel.viewData.soc)
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                                Text("%")
                                    .frame(width: 30)
                            }
                        }
                    } footer: {
                        VStack(alignment: .leading) {
                            Text("Your system monitors the power being imported from the grid. If the import exceeds your Import Limit of \(viewModel.viewData.importLimit) and your battery's state of charge (SOC) is above \(viewModel.viewData.soc)%, the system discharges the battery to supply the excess demand, thereby “shaving” the peak load from the grid.\n\nThis operation continues as long as the battery’s state of charge (SOC) is above a certain threshold SOC.\n\nPeak shaving only operates when you have the Peak Shaving mode enabled from the Inverter scheduler.")
                        }
                    }
                } else {
                    Text("Peak shaving is not available. This could be due to your inverter firmware or model.\n\nPlease contact FoxESS for further information.")
                }
            }

            BottomButtonsView(dirty: viewModel.isDirty) {
                viewModel.save()
            }
        }
        .navigationTitle(.peakShaving)
        .navigationBarTitleDisplayMode(.inline)
        .loadable(viewModel.state, retry: { viewModel.load() })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationStack {
        PeakShavingView(networking: NetworkService.preview(),
                        config: ConfigManager.preview())
    }
}
