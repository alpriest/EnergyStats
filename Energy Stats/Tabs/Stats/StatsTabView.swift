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
    @StateObject var viewModel: StatsTabViewModel
    @State private var valuesAtTime: ValuesAtTime?
    @State private var selectedDate: Date?
    private let appTheme: AppTheme

    init(configManager: ConfigManaging, networking: Networking, appTheme: AppTheme) {
        _viewModel = .init(wrappedValue: StatsTabViewModel(networking: networking, configManager: configManager))
        self.appTheme = appTheme
    }

    var body: some View {
        Group {
            VStack {
                DatePickerView(viewModel: DatePickerViewModel($viewModel.displayMode))
                    .padding(.horizontal)

                ScrollView {
                    StatsGraphView(data: viewModel.data, unit: viewModel.unit, stride: 3)
                        .frame(height: 250)
                        .padding(.vertical)

                    StatsGraphVariableToggles(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime)
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
        StatsTabView(configManager: PreviewConfigManager(), networking: DemoNetworking(), appTheme: AppTheme.mock())
            .previewDevice("iPhone 13 Mini")
    }
}
#endif
