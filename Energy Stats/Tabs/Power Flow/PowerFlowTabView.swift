//
//  SummaryTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct PowerFlowTabView: View {
    @ObservedObject var viewModel: PowerFlowTabViewModel

    var body: some View {
        VStack {
            switch viewModel.state {
            case let .loaded(summary):
                VStack {
                    HomePowerFlowView(viewModel: summary)
                }
                .padding()

                Spacer()

                Text(viewModel.updateState)
                    .monospacedDigit()
                    .font(.caption)
                    .foregroundColor(.gray)
            case let .failed(reason):
                Spacer()
                ErrorAlertView(retry: {
                    Task { await viewModel.timerFired() }
                }, details: reason)
                Spacer()
            case .unloaded:
                Spacer()
                HStack(spacing: 6) {
                    ProgressView()
                    Text("Loading...")
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundGradient.edgesIgnoringSafeArea(.all))
        .task {
            await viewModel.timerFired()
        }
        .onDisappear {
            Task { await viewModel.stopTimer() }
        }
    }

    private var backgroundGradient: some View {
        switch viewModel.state {
        case .loaded:
            return LinearGradient(colors: [Color("Sunny"), Color.clear], startPoint: UnitPoint(x: -0.6, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.5))
        case .failed:
            return LinearGradient(colors: [Color.red.opacity(0.7), Color.clear], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        case .unloaded:
            return LinearGradient(colors: [Color.white.opacity(0.5), Color.clear], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        }
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        PowerFlowTabView(viewModel: PowerFlowTabViewModel(DemoNetworking(), configManager: MockConfigManager()))
    }
}
