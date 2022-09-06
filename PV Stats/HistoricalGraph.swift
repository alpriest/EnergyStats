//
//  HistoricalGraph.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI
import Charts

struct HistoricalGraph: View {
    let data: [PowerTime]

    var body: some View {
        Chart {
            ForEach(data, id: \.self) { datum in
                LineMark(
                    x: .value("Date", datum.date, unit: .hour),
                    y: .value("Value", datum.value)
                )
            }
        }
    }
}

struct HistoricalGraph_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalGraph(       data: [PowerTime(date: Date(timeIntervalSince1970: 1662415043), value: 1.0),
                                      PowerTime(date: Date(timeIntervalSince1970: 1662425143), value: 1.3),
                                      PowerTime(date: Date(timeIntervalSince1970: 1662435243), value: 1.4),
                                      PowerTime(date: Date(timeIntervalSince1970: 1662444343), value: 1.2),
                                      PowerTime(date: Date(timeIntervalSince1970: 1662455443), value: 0.8),
                                      PowerTime(date: Date(timeIntervalSince1970: 1662465543), value: 0.4)
                                     ]
        )
    }
}
