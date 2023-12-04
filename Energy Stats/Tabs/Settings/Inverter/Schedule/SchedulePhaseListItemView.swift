//
//  SchedulePhaseListItemView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct SchedulePhaseListItemView: View {
    let phase: SchedulePhase

    var body: some View {
        HStack {
            phase.color
                .frame(width: 5)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 4)

            VStack(alignment: .leading) {
                (Text(phase.start.formatted) + Text(" - ") + Text(phase.end.formatted)).bold()

                Text(phase.mode.name)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SchedulePhaseListItemView(phase: Schedule.preview().phases.first!)
}
