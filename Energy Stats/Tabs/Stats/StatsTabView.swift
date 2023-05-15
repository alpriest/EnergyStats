//
//  StatsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Charts
import Energy_Stats_Core
import SwiftUI

@available(iOS 16.0, *)
struct StatsTabView: View {
    @ObservedObject var viewModel: StatsTabViewModel
    @State private var valuesAtTime: ValuesAtTime?
    @State private var selectedDate: Date?

    var body: some View {
        Group {
            VStack {
                HStack {
                    Text("Years")
                    Text("2023")
                }
//                GraphHeaderView(displayMode: $viewModel.displayMode, showingVariables: $showingVariables)

                ScrollView {
//                    UsageGraphView(viewModel: viewModel,
//                                   selectedDate: $selectedDate,
//                                   valuesAtTime: $valuesAtTime)
//                        .frame(height: 250)
//                        .padding(.vertical)
//
//                    GraphVariablesToggles(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime)
                }
            }
            .padding()
        }
        .task {
            Task {
                await viewModel.load()
            }
        }
    }
}

@available(iOS 16.0, *)
struct StatsTabView_Previews: PreviewProvider {
    static var previews: some View {
        StatsTabView(viewModel: StatsTabViewModel())
            .previewDevice("iPhone 13 Mini")
    }
}
