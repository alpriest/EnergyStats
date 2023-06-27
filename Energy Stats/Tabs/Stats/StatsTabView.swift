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
    @State private var showingExporter = false
    private let appTheme: AppTheme

    init(configManager: ConfigManaging, networking: Networking, appTheme: AppTheme) {
        _viewModel = .init(wrappedValue: StatsTabViewModel(networking: networking, configManager: configManager))
        self.appTheme = appTheme
    }

    var body: some View {
        Group {
            VStack {
                DatePickerView(viewModel: DatePickerViewModel($viewModel.displayMode))

                ScrollView {
                    StatsGraphView(viewModel: viewModel, selectedDate: $viewModel.selectedDate, valuesAtTime: $viewModel.valuesAtTime)
                        .frame(height: 250)
                        .padding(.vertical)

                    StatsGraphVariableToggles(viewModel: viewModel, selectedDate: $viewModel.selectedDate, valuesAtTime: $viewModel.valuesAtTime, appTheme: appTheme)

                    if appTheme.showSelfSufficiencyEstimate, let estimate = viewModel.selfSufficiencyEstimate {
                        ZStack(alignment: .topLeading) {
                            Group {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.teal, lineWidth: 1)
                                    .background(Color.teal.opacity(0.1))

                                Text("Approximations")
                                    .padding(2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.teal)
                                    )
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .offset(x: 8, y: -8)
                                    .foregroundColor(.white)
                            }
                            .compositingGroup()

                            ZStack {
                                VStack {
                                    HStack {
                                        Text("Self sufficiency ")
                                        Spacer()
                                        Text(estimate)
                                    }
                                    if let home = viewModel.homeUsage {
                                        HStack {
                                            Text("Home usage ")
                                            Spacer()
                                            EnergyText(amount: home, appTheme: appTheme)
                                        }
                                    }
                                }
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                        }
                        .padding()
                    }

                    Text("Stats are aggregated by FoxESS into 1 hr, 1 day or 1 month totals")
                        .font(.footnote)
                        .foregroundColor(Color("text_dimmed"))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 28)

                    if let url = viewModel.exportFile?.url {
                        ShareLink(item: url) {
                            Label("Export graph data", systemImage: "square.and.arrow.up")
                        }
                    }
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
        StatsTabView(configManager: PreviewConfigManager(), networking: DemoNetworking(), appTheme: .mock())
            .previewDevice("iPhone 13 Mini")
    }
}
#endif
