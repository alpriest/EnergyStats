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
            case let .failed(reason):
                Text(reason)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task { await viewModel.timerFired() }
                }
            case .unloaded:
                Text("Loading...")
            }

            Spacer()

            HStack {
                Spacer()
                Text(viewModel.updateState)
                    .monospacedDigit()
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(backgroundGradient)
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
            return LinearGradient(colors: [Color("Sunny"), Color.clear], startPoint: UnitPoint(x: -0.6, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.5)).edgesIgnoringSafeArea(.all)
        case .failed:
            return LinearGradient(colors: [Color.red.opacity(0.7), Color.clear], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7)).edgesIgnoringSafeArea(.all)
        case .unloaded:
            return LinearGradient(colors: [Color.white.opacity(0.5), Color.clear], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7)).edgesIgnoringSafeArea(.all)
        }
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        PowerFlowTabView(viewModel: PowerFlowTabViewModel(MockNetworking(), configManager: MockConfigManager()))
    }
}
