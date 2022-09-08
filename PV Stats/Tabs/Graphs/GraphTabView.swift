//
//  GraphTabView.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Charts
import SwiftUI

struct GraphTabView: View {
    @ObservedObject var viewModel: GraphTabViewModel

    var body: some View {
        VStack {
            Chart(viewModel.data) {
                LineMark(
                    x: .value("Time", $0.date, unit: .minute),
                    y: .value("kW", $0.value),
                    series: .value("Title", $0.variable)
                )
                .foregroundStyle(viewModel.color(for: $0.variable))
            }

            VStack(alignment: .leading) {
                ForEach(viewModel.variables, id: \.self) { series in
                    Button(action: {
                        viewModel.toggle(series)
                    }) {
                        HStack {
                            Circle()
                                .foregroundColor(viewModel.color(for: series))
                                .frame(width: 15, height: 15)

                            Text(series)

                        }.foregroundColor(viewModel.isEnabled(series) ? Color.blue : Color.blue.opacity(0.3))
                    }
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.start()
        }
    }
}

struct GraphTabView_Previews: PreviewProvider {
    static var previews: some View {
        GraphTabView(viewModel: GraphTabViewModel(MockNetworking()))
    }
}
