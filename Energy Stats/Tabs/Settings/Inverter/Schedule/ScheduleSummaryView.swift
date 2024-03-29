//
//  ScheduleSummaryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleSummaryView: View {
    private let networking: Networking
    private let config: ConfigManaging
    @StateObject var viewModel: ScheduleSummaryViewModel

    init(networking: Networking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: ScheduleSummaryViewModel(networking: networking, config: config))
        self.networking = networking
        self.config = config
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .inactive:
                content()
            case let .error(_, reason):
                Text(reason)
                    .multilineTextAlignment(.center)
            case let .active(reason):
                Spacer()
                HStack(spacing: 8) {
                    Text(reason)
                    ProgressView()
                }
                Spacer()
            }
        }
        .onAppear {
            Task { await self.viewModel.load() }
        }
        .navigationTitle("Work schedule")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content() -> some View {
        VStack(spacing: 0) {
            Form {
                Toggle(isOn: $viewModel.schedulerEnabled) {
                    Text("Enable Scheduler")
                }

                if let schedule = viewModel.schedule {
                    if schedule.phases.count > 0 {
                        Section {
                            NavigationLink(destination: {
                                               EditScheduleView(
                                                   networking: networking,
                                                   config: config,
                                                   schedule: schedule
                                               )
                                           },
                                           label: {
                                               ScheduleView(schedule: schedule)
                                                   .padding(.vertical, 4)
                                           })
                        } header: {
                            Text("active_schedule_title")
                        }
                    } else {
                        NavigationLink(destination: {
                            EditScheduleView(
                                networking: networking,
                                config: config,
                                schedule: schedule
                            )
                        }, label: {
                            Text("Create a schedule")
                        })
                    }
                }

                FooterSection {
                    Text("templates_not_yet_available")
                }

//                Section {
//                    ForEach(viewModel.templates) { template in
//                        HStack {
//                            Text(template.name)
//
//                            Spacer()
//
//                            Button {
//                                Task { await viewModel.activate(templateID: template.id) }
//                            } label: {
//                                Text("Activate")
//                            }
//                            .buttonStyle(.borderedProminent)
//                        }
//                    }
//                } header: {
//                    Text("Templates")
//                        .padding(.top, 24)
//                } footer: {
//                    VStack {
//                        NavigationLink {
//                            ScheduleTemplateListView(networking: networking, config: config, modes: viewModel.modes)
//                        } label: {
//                            Text("Manage templates")
//                        }.buttonStyle(.borderedProminent)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.top)
//                }
            }
        }
        .loadable(viewModel.state, retry: { Task { await viewModel.load() } })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationView {
        ScheduleSummaryView(
            networking: DemoNetworking(),
            config: PreviewConfigManager()
        )
    }
}
