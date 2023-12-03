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
                .fill(Color.black.opacity(0.1))
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
