//
//  ScheduleDetailView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/12/2023.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct ScheduleDetailView: View {
    let schedule: Schedule
    let configManager: ConfigManaging
    let onUpdate: (SchedulePhase) -> Void
    let onDelete: (String) -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                TimePeriodBarView(phases: schedule.phases)
                    .padding(.bottom, 22)
            }
        }

        if schedule.phases.count == 0 {
            FooterSection {
                Text("You have no time periods defined. Add a time period to define how you'd like your inverter to behave during specific hours.")
            }
        }

        ForEachIndexed(schedule.phases) { index, phase in
            NavigationLink {
                SchedulePhaseEditView(phase: phase,
                                      configManager: configManager,
                                      onChange: onUpdate,
                                      onDelete: onDelete)
            } label: {
                SchedulePhaseListItemView(phase: phase)
                    .if(index >= Schedule.maxPhasesCount) {
                        $0.overlay(
                            // Diagonal stripes
                            CrossHatchView()
                        )
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScheduleDetailView(
        schedule: Schedule.preview(),
        configManager: ConfigManager.preview(),
        onUpdate: { _ in },
        onDelete: { _ in }
    )
}

struct ForEachIndexed<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let content: (Data.Index, Data.Element) -> Content

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Index, Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some View {
        ForEach(Array(zip(data.indices, data)), id: \.1.id) { index, element in
            content(index, element)
        }
    }
}
