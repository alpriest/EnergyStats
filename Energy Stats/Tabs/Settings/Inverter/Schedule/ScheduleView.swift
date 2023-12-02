//
//  StrategyView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 29/11/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleView: View {
    @StateObject var viewModel: ScheduleViewModel

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: ScheduleViewModel(networking: networking, config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            if let schedule = viewModel.schedule {
                loaded(schedule: schedule)

                BottomButtonsView { viewModel.save() }
            }
        }
        .task { viewModel.load() }
        .navigationTitle("Inverter Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .loadable($viewModel.state, retry: { viewModel.load() })
        .alert(alertContent: $viewModel.alertContent)
    }

    private func loaded(schedule: Schedule) -> some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    Text(schedule.name)
                        .font(.title2)
                        .padding(.bottom)

                    TimePeriodBarView(phases: schedule.phases)
                        .padding(.bottom, 22)
                }
            }

            ForEach(schedule.phases) { phase in
                NavigationLink(destination: {
                    SchedulePhaseView(modes: viewModel.modes, phase: phase) { phase in
                        viewModel.updated(phase: phase)
                    }
                }, label: {
                    HStack {
                        phase.color
                            .frame(width: 5)
                            .frame(maxHeight: .infinity)
                            .padding(.vertical, 4)

                        VStack(alignment: .leading) {
                            (Text(phase.start.formatted) + Text(" - ") + Text(phase.end.formatted)).bold()

                            Text(phase.mode.name)
                        }
                    }
                })
            }
            .frame(maxWidth: .infinity)

            Button {
                viewModel.addNewPhase()
            } label: {
                Text("Add new phase")
            }
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
    NavigationView {
        ScheduleView(
            networking: DemoNetworking(),
            config: PreviewConfigManager()
        )
    }
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
                    mode: SchedulerModeResponse(color: "#00ff00", name: "Force charge", key: "ForceDischarge"),
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
                    mode: SchedulerModeResponse(color: "#ff0000", name: "Force discharge", key: "ForceDischarge"),
                    forceDischargePower: 3500,
                    forceDischargeSOC: 20,
                    batterySOC: 20,
                    color: .linesPositive
                )!
            ]
        )
    }
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
