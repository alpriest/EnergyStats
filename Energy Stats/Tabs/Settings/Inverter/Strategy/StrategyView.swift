//
//  StrategyView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/11/2023.
//

import Energy_Stats_Core
import SwiftUI

struct StrategyPhase: Identifiable {
    let start: Time
    let end: Time
    let mode: String
    let id = UUID().uuidString
    let color: Color

    var startPoint: CGFloat { CGFloat(minutesAfterMidnight(start)) / (24 * 60) }
    var endPoint: CGFloat { CGFloat(minutesAfterMidnight(end)) / (24 * 60) }

    private func minutesAfterMidnight(_ time: Time) -> Int {
        (time.hour * 60) + time.minute
    }
}

struct StrategyView: View {
    let phases: [StrategyPhase]

    var body: some View {
        VStack {
            Text("Strategy name")

            VStack(alignment: .leading) {
                HStack {
                    Text("00:00")

                    Spacer()

                    Text("24:00")
                }
                .font(.caption2)

                Rectangle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 20)
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

                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
                    .overlay(
                        GeometryReader { reader in
                            ZStack(alignment: .leading) {
                                ForEach(phases) { phase in
                                    Text(phase.start.formatted)
                                        .offset(x: reader.size.width * phase.startPoint)
                                }
                            }
                        }
                    )
                    .font(.caption2)
            }
            .frame(width: .infinity, alignment: .leading)

            VStack {
                ForEach(phases) { phase in
                    Card {
                        HStack {
                            phase.color
                                .frame(width: 10, height: 10)

                            Text(phase.start.formatted) + Text(" - ") + Text(phase.end.formatted)
                            Text(phase.mode)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    private var shouldHideDayStart: Bool {
        phases.anySatisfy { phase in
            phase.start < Time(hour: 2, minute: 0)
        }
    }

    private var shouldHideDayEnd: Bool {
        phases.anySatisfy { phase in
            phase.start > Time(hour: 20, minute: 0)
        }
    }
}

struct Card<T: View>: View {
    let content: () -> T

    var body: some View {
        VStack(alignment: .leading) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    StrategyView(
        phases: [
            StrategyPhase(start: Time(hour: 1, minute: 00), end: Time(hour: 2, minute: 00), mode: "Force charge", color: .linesNegative),
            StrategyPhase(start: Time(hour: 19, minute: 30), end: Time(hour: 23, minute: 30), mode: "Force discharge", color: .linesPositive),
        ]
    )
}

private extension Date {
    func todayAt(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        return calendar.date(from: dateComponents)!
    }
}
