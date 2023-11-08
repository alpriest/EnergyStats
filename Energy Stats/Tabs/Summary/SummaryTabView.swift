//
//  SummaryTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/11/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct SummaryTabView: View {
    @StateObject var viewModel: SummaryTabViewModel
    @State private var appTheme: AppTheme
    private var appThemePublisher: LatestAppTheme

    init(configManager: ConfigManaging, networking: Networking, appThemePublisher: LatestAppTheme) {
        _viewModel = .init(wrappedValue: SummaryTabViewModel(configManager: configManager, networking: networking))
        self.appThemePublisher = appThemePublisher
        self.appTheme = appThemePublisher.value
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if viewModel.isLoading {
                        Group {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "chart.bar.xaxis.ascending")
                                    .font(.system(size: 72))
                                    .symbolEffect(.variableColor.iterative, options: .repeating)
                            } else {
                                Image(systemName: "chart.bar.xaxis.ascending")
                            }
                        }
                    } else {
                        if let approximationsViewModel = viewModel.approximationsViewModel {
                            ApproximationsView(viewModel: approximationsViewModel, appTheme: appTheme, decimalPlaceOverride: 0)
                        } else {
                            Text("Could not load approximations")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
        }
        .onAppear {
            viewModel.load()
        }
        .onReceive(appThemePublisher) {
            self.appTheme = $0
        }
    }
}

#Preview {
    SummaryTabView(configManager: PreviewConfigManager(),
                   networking: DemoNetworking(),
                   appThemePublisher: CurrentValueSubject(.mock()))
}
