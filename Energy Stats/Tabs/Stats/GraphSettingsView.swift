//
//  GraphSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 28/02/2026.
//

import Energy_Stats_Core
import SwiftUI

struct GraphSettingsView: View {
    @Binding var statsTimeUsageGraphStyle: StatsTimeUsageGraphStyle
    @Binding var showingEnergyBreakdownGraph: Bool

    var body: some View {
        Form {
            Section {
                Picker(selection: $statsTimeUsageGraphStyle) {
                    ForEach(StatsTimeUsageGraphStyle.allCases, id: \.self) {
                        Text($0.title)
                    }
                } label: {
                    Text("Time usage graph")
                }.pickerStyle(.segmented)
            } header: {
                Text("Time usage graph")

            } footer: {
                Text("Shows how your energy changes over the selected time period.")
            }

            Section {
                VStack(alignment: .leading) {
                    Text("Energy source usage graph")
                    
                    Picker(selection: $showingEnergyBreakdownGraph) {
                        Text("Hidden").tag(false)
                        Text("Shown").tag(true)
                    } label: {
                        Text("Energy breakdown graph")
                    }.pickerStyle(.segmented)
                }
            } footer: {
                Text("Shows total energy generation and usage for the selected period.")
            }
        }
    }
}

#Preview {
    GraphSettingsView(
        statsTimeUsageGraphStyle: .constant(.line),
        showingEnergyBreakdownGraph: .constant(true)
    )
}
