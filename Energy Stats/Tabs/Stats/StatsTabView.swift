//
//  StatsTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Charts
import Energy_Stats_Core
import SwiftUI

enum StatsDisplayMode: Equatable {
    case day(Date)
    case month(_ month: Int, _ year: Int)
    case year(Int)
}

@available(iOS 16.0, *)
struct StatsTabView: View {
    @ObservedObject var viewModel: StatsTabViewModel
    @State private var valuesAtTime: ValuesAtTime?
    @State private var selectedDate: Date?

    var body: some View {
        Group {
            VStack {
                DatePickerView(viewModel: DatePickerViewModel($viewModel.displayMode))
                    .padding(.horizontal)

                ScrollView {
                    UsageGraphView(viewModel: viewModel,
                                   selectedDate: $selectedDate,
                                   valuesAtTime: $valuesAtTime)
                        .frame(height: 250)
                        .padding(.vertical)

                    Text(String(describing: viewModel.displayMode))
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

#if DEBUG
@available(iOS 16.0, *)
struct StatsTabView_Previews: PreviewProvider {
    static var previews: some View {
        StatsTabView(viewModel: StatsTabViewModel(networking: DemoNetworking(), configManager: PreviewConfigManager()))
            .previewDevice("iPhone 13 Mini")
    }
}
#endif
