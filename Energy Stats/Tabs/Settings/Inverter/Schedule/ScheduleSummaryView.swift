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
                Section {
                    if let schedule = viewModel.schedule {
                        ScheduleView(schedule: schedule, modes: viewModel.modes)
                    } else {
                        Text("You don't have a schedule defined.")
                    }
                } header: {
                    Text("Current Schedule")
                }

                Section {
                    ForEach(viewModel.templates) { template in
                        HStack {
                            Text(template.name)
                            Spacer()
                            Button {
                                Task { await viewModel.enable(templateID: template.id) }
                            } label: {
                                Text("Enable")
                            }
                        }
                    }
                } header: {
                    Text("Templates")
                } footer: {
                    NavigationLink {
                        ScheduleTemplateListView(networking: networking, config: config)
                    } label: {
                        Text("Manage templates")
                    }
                }
            }
        }
        .loadable($viewModel.state, retry: { Task { await viewModel.load() } })
        .navigationTitle("Work model")
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
