//
//  TimePeriodBarView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/11/2023.
//

import SwiftUI
import Energy_Stats_Core
struct TimePeriodBarView: View {
    let phases: [SchedulePhase]
    private let height: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.orange.opacity(0.1))
                .frame(height: height)
                .overlay(
                    GeometryReader { reader in
                        ZStack(alignment: .leading) {
                            ForEach(phases) { phase in
                                Rectangle()
                                    .fill(phase.color)
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

                Text("24:00")
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
            name: nil,
            phases: [
                SchedulePhase(
                    start: Time(
                        hour: 1,
                        minute: 00
                    ),
                    end: Time(
                        hour: 2,
                        minute: 00
                    ),
                    mode: SchedulerModeResponse(color: "#00ff00", name: "Force charge", key: "ForceCharge"),
                    forceDischargePower: 0,
                    forceDischargeSOC: 100,
                    batterySOC: 100,
                    color: .linesNegative
                )!,
                SchedulePhase(
                    start: Time(
                        hour: 10,
                        minute: 30
                    ),
                    end: Time(
                        hour: 14,
                        minute: 30
                    ),
                    mode: SchedulerModeResponse(color: "#ff0000", name: "Force discharge", key: "ForceDischarge"),
                    forceDischargePower: 3500,
                    forceDischargeSOC: 20,
                    batterySOC: 20,
                    color: .linesPositive
                )!,
                SchedulePhase(
                    start: Time(
                        hour: 19,
                        minute: 30
                    ),
                    end: Time(
                        hour: 23,
                        minute: 30
                    ),
                    mode: SchedulerModeResponse(color: "#ff0000", name: "Self Use", key: "SelfUse"),
                    forceDischargePower: 0,
                    forceDischargeSOC: 20,
                    batterySOC: 20,
                    color: .paleGray
                )!
            ]
        )
    }
}
