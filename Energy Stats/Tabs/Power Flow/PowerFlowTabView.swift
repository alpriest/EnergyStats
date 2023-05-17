//
//  PowerFlowTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import SwiftUI
import Energy_Stats_Core

struct PowerFlowTabView: View {
    let appTheme: AppTheme
    @StateObject private var viewModel: PowerFlowTabViewModel

    init(configManager: ConfigManaging, networking: Networking, appTheme: AppTheme) {
        _viewModel = .init(wrappedValue: PowerFlowTabViewModel(networking, configManager: configManager))
        self.appTheme = appTheme
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case let .loaded(summary):
                HomePowerFlowView(configManager: viewModel.configManager, viewModel: summary, appTheme: appTheme)

                Spacer()

                Text(viewModel.updateState)
                    .monospacedDigit()
                    .font(.caption)
                    .foregroundColor(Color("text_dimmed"))
            case let .failed(error, reason):
                Spacer()
                ErrorAlertView(cause: error, message: reason) {
                    Task { await viewModel.timerFired() }
                }
                Spacer()
            case .unloaded:
                Spacer()
                HStack(spacing: 8) {
                    Text("Loading")
                    ProgressView()
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(background().edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.viewAppeared()
        }
    }

    @ViewBuilder func background() -> some View {
        switch appTheme.showSunnyBackground {
        case true:
            backgroundGradient
        case false:
            Color("background")
        }
    }

    private var backgroundGradient: some View {
        switch viewModel.state {
        case .loaded:
            return LinearGradient(colors: [Color("Sunny"), Color("background")], startPoint: UnitPoint(x: -0.6, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.5))
        case .failed:
            return LinearGradient(colors: [Color.red.opacity(0.7), Color("background")], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        case .unloaded:
            return LinearGradient(colors: [Color.white.opacity(0.5), Color("background")], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        }
    }
}

struct PowerFlowTabView_Previews: PreviewProvider {
    static var previews: some View {
        PowerFlowTabView(configManager: PreviewConfigManager(), networking: DemoNetworking(),
                         appTheme: AppTheme.mock())
    }
}
