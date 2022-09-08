//
//  PowerGraph.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Charts
import SwiftUI

struct PowerGraph: View {
    let current: CGFloat
    let maximum: CGFloat

    var body: some View {
        Chart {
            BarMark(
                x: .value("date", Date(), unit: .day),
                y: .value("kWh", Double(current))
            )
            .foregroundStyle(Color.red.gradient)
            .annotation(position: .top) {
                Text(String(format: "%.2f kWh", current))
            }
        }
        .frame(width: 100, height: 250)
        .background(Color.gray.opacity(0.1))
        .chartXAxis(.hidden)
        .chartYScale(domain: 0 ... Double(maximum))
    }
}

struct PowerGraph_Previews: PreviewProvider {
    static var previews: some View {
        PowerGraph(current: 1.4, maximum: 4.0)
    }
}
