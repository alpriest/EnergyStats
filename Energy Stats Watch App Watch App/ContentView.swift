//
//  ContentView.swift
//  Energy Stats Watch App Watch App
//
//  Created by Alistair Priest on 03/04/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        ScrollView {
            VStack {
                if let summary = viewModel.summary {
                    LazyVGrid(columns: [GridItem(.fixed(45)), GridItem(.flexible())], spacing: 10) {
                        Image(systemName: "sun.max")
                            .font(.system(size: 32))

                        HStack {
                            Text(NSNumber(value: summary.solar), formatter: formatter) + Text(" kW")
                        }

                        PylonView()
                            .frame(width: 34, height: 30)

                        HStack {
                            if summary.grid < 0 {
                                Image(systemName: "arrow.left")
                            }
                            Text(NSNumber(value: abs(summary.grid)), formatter: formatter) + Text(" kW")
                            if summary.grid > 0 {
                                Image(systemName: "arrow.right")
                            }
                        }.foregroundColor(summary.grid > 0 ? Color.green : Color.red)

                        Image(systemName: "minus.plus.batteryblock.fill")
                            .font(.system(size: 32))

                        VStack {
                            Text(summary.batteryStateOfCharge, format: .percent)
                            //                        if let batteryMessage = viewModel.batteryMessage {
                            //                            Text(batteryMessage)
                            //                                .font(.footnote)
                            //                        }
                        }
                    }
                    .padding(.bottom, 12)
                }

                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(viewModel.updateState)
                        .font(.footnote)
                }
            }
        }
        .padding()
        .task {
            await viewModel.timerFired()
        }
        .onDisappear {
            Task { await viewModel.stopTimer() }
        }
    }

    let formatter: NumberFormatter = {
        let result = NumberFormatter()
        result.maximumFractionDigits = 3
        result.minimumFractionDigits = 3
        return result
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(viewModel: ContentViewModel(DemoNetworking(), configManager: PreviewConfigManager()))
        }
    }
}
