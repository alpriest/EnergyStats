//
//  SummaryTabView2.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/11/2023.
//

import Charts
import Energy_Stats_Core
import SwiftUI

struct UsageData: Identifiable {
    let year: String
    let usage: Double
    let exportIncome: Double
    let gridImportAvoided: Double
    var id: Int { Int(year) ?? -1 }
}

@available(iOS 16.0, *)
struct SummaryTabView2: View {
    let data = [UsageData(year: "2021", usage: 10, exportIncome: 24.50, gridImportAvoided: 700.23),
                UsageData(year: "2022", usage: 20, exportIncome: 74.50, gridImportAvoided: 700.23),
                UsageData(year: "2023", usage: 30, exportIncome: 71.50, gridImportAvoided: 700.23)]
    let appTheme: AppTheme
    @State var showingYearlyBreakdown = false
    @State var amount: Double = 0

    var body: some View {
        VStack(spacing: 44) {
            HStack {
                Text("Usage")
                AnimatedNumber(target: 60) {
                    EnergyText(amount: $0, appTheme: appTheme, type: .default, decimalPlaceOverride: 0)
                }

                Button(action: {
                    withAnimation {
                        showingYearlyBreakdown.toggle()
                    }
                }, label: {
                    Text(showingYearlyBreakdown ? "Hide breakdown" : "Show breakdown")
                })
            }

            if showingYearlyBreakdown {
                VStack(spacing: 8) {
                    Text("Energy Usage")
                        .font(.title2)

                    Chart {
                        ForEach(data) { data in
                            BarMark(
                                x: .value("Year", data.year),
                                y: .value("kWh", data.usage)
                            )
                            .annotation(position: .top) {
                                EnergyText(amount: data.usage, appTheme: appTheme, type: .default, decimalPlaceOverride: 0)
                            }
                        }
                        .foregroundStyle(Color.blue.gradient)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 200)
                }

                VStack(spacing: 8) {
                    Text("Financials")
                        .font(.title2)

                    Chart {
                        ForEach(data) { data in
                            BarMark(
                                x: .value("Year", data.year),
                                y: .value("Export income", data.exportIncome)
                            )
                            .annotation(position: .top) {
                                Text(data.exportIncome, format: .number)
                            }
                            .position(by: .value("parameter", "a"))

                            BarMark(
                                x: .value("Year", data.year),
                                y: .value("Grid Import Avoided", data.gridImportAvoided)
                            )
                            .annotation(position: .top) {
                                Text(data.gridImportAvoided, format: .number)
                            }
                            .position(by: .value("parameter", "b"))
                        }
                        .foregroundStyle(Color.blue.gradient)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .frame(height: 200)
                }
            }
        }.onAppear(perform: {
            withAnimation {
                amount = 60
            }
        })
    }
}

@available(iOS 16.0, *)
#Preview {
    SummaryTabView2(appTheme: AppTheme.mock())
}
