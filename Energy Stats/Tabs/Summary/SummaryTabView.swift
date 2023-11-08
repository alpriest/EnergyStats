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
    @ObservedObject var viewModel: SummaryTabViewModel
    @State private var appTheme: AppTheme
    private var appThemePublisher: LatestAppTheme

    init(configManager: ConfigManaging, networking: Networking, appThemePublisher: LatestAppTheme) {
        _viewModel = .init(wrappedValue: SummaryTabViewModel(configManager: configManager, networking: networking))
        self.appThemePublisher = appThemePublisher
        self.appTheme = appThemePublisher.value
    }

    var body: some View {
        ScrollView {
            VStack {
                if viewModel.isLoading {
                    if #available(iOS 17.0, *) {
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .symbolEffect(.variableColor.iterative, options: .repeating, value: viewModel.isLoading)
                    } else {
                        Image(systemName: "chart.bar.xaxis.ascending")
                    }
                } else {
                    if let approximationsViewModel = viewModel.approximationsViewModel {
                        ApproximationsView(viewModel: approximationsViewModel, appTheme: appTheme)
                    } else {
                        Text("Could not load approximations")
                    }
                }
            }
        }.onAppear {
            viewModel.load()
        }
    }
}

#Preview {
    SummaryTabView(configManager: PreviewConfigManager(),
                   networking: DemoNetworking(),
                   appThemePublisher: CurrentValueSubject(.mock()))
}
