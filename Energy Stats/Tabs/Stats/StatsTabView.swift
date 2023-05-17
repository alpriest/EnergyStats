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

    func unit() -> Calendar.Component {
        switch self {
        case .day:
            return .hour
        case .month:
            return .day
        case .year:
            return .month
        }
    }
}

@available(iOS 16.0, *)
struct StatsTabView: View {
    @StateObject var viewModel: StatsTabViewModel
    @State private var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    @State private var selectedDate: Date?

    init(configManager: ConfigManaging, networking: Networking) {
        _viewModel = .init(wrappedValue: StatsTabViewModel(networking: networking, configManager: configManager))
    }

    var body: some View {
        Group {
            VStack {
                DatePickerView(viewModel: DatePickerViewModel($viewModel.displayMode))

                ScrollView {
                    StatsGraphView(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime)
                        .frame(height: 250)
                        .padding(.vertical)

                    StatsGraphVariableToggles(viewModel: viewModel, selectedDate: $selectedDate, valuesAtTime: $valuesAtTime)

                    Text("Stats are aggregated by FoxESS into 1 hr, 1 day or 1 month totals")
                        .font(.footnote)
                        .foregroundColor(Color("text_dimmed"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 44)
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
        StatsTabView(configManager: PreviewConfigManager(), networking: DemoNetworking())
            .previewDevice("iPhone 13 Mini")
    }
}
#endif
