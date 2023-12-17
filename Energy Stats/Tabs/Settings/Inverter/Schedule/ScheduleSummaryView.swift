//
//  ScheduleSummaryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleSummaryView: View {
    private let networking: FoxESSNetworking
    private let config: ConfigManaging
    @StateObject var viewModel: ScheduleSummaryViewModel

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: ScheduleSummaryViewModel(networking: networking, config: config))
        self.networking = networking
        self.config = config
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                if let schedule = viewModel.schedule {
                    if schedule.phases.count > 0 {
                        Section {
                            NavigationLink(destination: {
                                               EditScheduleView(
                                                   networking: networking,
                                                   config: config,
                                                   schedule: schedule,
                                                   modes: viewModel.modes,
                                                   allowDelete: true
                                               )
                                           },
                                           label: {
                                               ScheduleView(schedule: schedule)
                                                   .padding(.vertical, 4)
                                           })
                        } header: {
                            Text("Current schedule")
                        }
                    } else {
                        VStack {
                            Text("You don't have a schedule defined.")
                                .padding(.vertical, 44)
                        }

                        NavigationLink(destination: {
                            EditScheduleView(
                                networking: networking,
                                config: config,
                                schedule: schedule,
                                modes: viewModel.modes,
                                allowDelete: false
                            )
                        }, label: {
                            Text("Create a schedule")
                        })
                    }
                }

                Section {
                    ForEach(viewModel.templates) { template in
                        HStack {
                                Text(template.name)

                            Spacer()
                            
                            Button {
                                Task { await viewModel.activate(templateID: template.id) }
                            } label: {
                                Text("Activate")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                } header: {
                    Text("Templates")
                        .padding(.top, 24)
                } footer: {
                    VStack(alignment: .leading) {
                        NavigationLink {
                            ScheduleTemplateListView(networking: networking, config: config, modes: viewModel.modes)
                        } label: {
                            Text("Manage templates")
                        }
                    }
                }
            }
        }
        .loadable($viewModel.state, retry: { Task { await viewModel.load() } })
        .navigationTitle("Work strategy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await self.viewModel.load() }
        }
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
