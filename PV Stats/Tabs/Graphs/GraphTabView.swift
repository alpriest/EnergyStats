//
//  GraphTabView.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI
import Charts

struct GraphTabView: View {
    @ObservedObject var viewModel: GraphTabViewModel

    var body: some View {
        Chart(viewModel.data) {
            LineMark(
                x: .value("Time", $0.date, unit: .minute),
                y: .value("kW", $0.value)
            )
            .foregroundStyle(by: .value("Title", $0.variable))
        }
//        .chartLegend(position: .automatic) {
//            Text("hi")
//        }
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
