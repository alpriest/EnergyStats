//
//  SummaryTabView.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct SummaryTabView: View {
    @ObservedObject var viewModel: SummaryTabViewModel

    var body: some View {
        VStack(spacing: 44) {
            if let summary = viewModel.summary {
                VStack {
                    PowerSummaryView(viewModel: summary)
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text(viewModel.updateState)
                Spacer()
            }.foregroundColor(.gray)
        }
        .padding()
        .background(backgroundGradient)
        .onAppear {
            viewModel.loadData()
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(colors: [Color.yellow.opacity(0.5), Color.clear], startPoint: UnitPoint(x: 0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
            .edgesIgnoringSafeArea(.all)
    }
}

struct SummaryTabView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryTabView(viewModel: SummaryTabViewModel(MockNetworking()))
            .preferredColorScheme(.dark)
    }
}
