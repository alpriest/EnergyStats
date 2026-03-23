//
//  TimePeriodBarView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/11/2023.
//

import Energy_Stats_Core
import SwiftUI

struct TimePeriodBarView: View {
    let phases: [SchedulePhaseV3]
    private let height: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.orange.opacity(0.1))
                .frame(height: height)
                .overlay(
                    GeometryReader { reader in
                        ZStack(alignment: .leading) {
                            ForEach(phases.filter { $0.enabled }) { phase in
                                Rectangle()
                                    .fill(phase.displayColor)
                                    .frame(width: reader.size.width * (phase.endPoint - phase.startPoint))
                                    .offset(x: reader.size.width * phase.startPoint)
                            }
                        }
                    }
                )

            HStack {
                Text("00:00")

                Spacer()

                Text("08:00")

                Spacer()

                Text("16:00")

                Spacer()

                Text("23:59")
            }
            .font(.caption2)
        }
    }
}

#Preview {
    TimePeriodBarView(phases: Schedule.preview().phases)
}

extension Schedule {
    static func preview() -> Schedule {
        Schedule(
            phases: [
                .preview.copy(enabled: false, mode: WorkMode.ForceCharge, start: Time(hour: 1, minute: 00), end: Time(hour: 2, minute: 00)),
                .preview.copy(mode: WorkMode.ForceDischarge, start: Time(hour: 8, minute: 00), end: Time(hour: 14, minute: 00)),
                .preview.copy(mode: WorkMode.SelfUse, start: Time(hour: 19, minute: 30), end: Time(hour: 23, minute: 30)),
                .preview.copy(mode: WorkMode.ForceCharge, start: Time(hour: 1, minute: 0), end: Time(hour: 2, minute: 0)),
                .preview.copy(mode: WorkMode.ForceDischarge, start: Time(hour: 8, minute: 0), end: Time(hour: 14, minute: 30)),
                .preview.copy(mode: WorkMode.SelfUse, start: Time(hour: 19, minute: 30), end: Time(hour: 23, minute: 30)),
                .preview.copy(mode: WorkMode.ForceCharge, start: Time(hour: 1, minute: 30), end: Time(hour: 2, minute: 0))
            ]
        )
    }
}
