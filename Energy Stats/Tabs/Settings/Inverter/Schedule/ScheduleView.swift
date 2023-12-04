//
//  ScheduleView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleView: View {
    let schedule: Schedule

    var body: some View {
        VStack {
            TimePeriodBarView(phases: schedule.phases)
                .padding(.bottom, 22)

            ForEach(schedule.phases) { phase in
                SchedulePhaseListItemView(phase: phase)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ScheduleView(
        schedule: Schedule.preview()
    )
}
