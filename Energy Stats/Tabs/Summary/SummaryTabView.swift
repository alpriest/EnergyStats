//
//  SummaryTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct SummaryTabView: View {
    @ObservedObject var viewModel: SummaryTabViewModel
    @State private var nextUpdate = " "

    var body: some View {
        VStack {
            switch viewModel.state {
            case let .loaded(summary):
                VStack {
                    PowerSummaryView(viewModel: summary)
                }
                .padding()
            case let .failed(reason):
                Text(reason)
                    .multilineTextAlignment(.center)
            case .unloaded:
                Text("Loading...")
            }

            Spacer()

            HStack {
                Spacer()
                Text(nextUpdate)
                Spacer()
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(backgroundGradient)
        .task {
            await viewModel.loadData()
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: viewModel.updateState) { newValue in
            withAnimation {
                nextUpdate = newValue
            }
        }
    }

    private var backgroundGradient: some View {
        switch viewModel.state {
        case .loaded:
            return LinearGradient(colors: [Color("Sunny"), Color.clear], startPoint: UnitPoint(x: 0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7)).edgesIgnoringSafeArea(.all)
        case .failed:
            return LinearGradient(colors: [Color.red.opacity(0.7), Color.clear], startPoint: UnitPoint(x: 0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7)).edgesIgnoringSafeArea(.all)
        case .unloaded:
            return LinearGradient(colors: [Color.white.opacity(0.5), Color.clear], startPoint: UnitPoint(x: 0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7)).edgesIgnoringSafeArea(.all)
        }
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTabView(viewModel: SummaryTabViewModel(MockNetworking()))
    }
}
