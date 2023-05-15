//
//  StatsGraphView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import SwiftUI
import Charts

struct StatsGraphView: View {
    

    var body: some View {
//        Chart(viewModel.data, id: \.variable.variable) {
//            LineMark(
//                x: .value("hour", $0.date),
//                y: .value("", $0.value),
//                series: .value("Title", $0.variable.name) //TODO: (as: .snapshot))
//            )
//            .foregroundStyle($0.variable.colour)
//        }
//        .chartPlotStyle { content in
//            content.background(Color.gray.gradient.opacity(0.02))
//        }
        Text("hi")
    }
}

struct StatsGraphView_Previews: PreviewProvider {
    static var previews: some View {
        StatsGraphView()
    }
}
