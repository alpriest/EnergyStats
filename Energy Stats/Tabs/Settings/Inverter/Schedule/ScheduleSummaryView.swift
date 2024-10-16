//
//  ScheduleSummaryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import StoreKit
import SwiftUI

struct ScheduleSummaryView: View {
    private let networking: Networking
    private let config: ConfigManaging
    private let templateStore: TemplateStoring
    @StateObject var viewModel: ScheduleSummaryViewModel

    init(networking: Networking, config: ConfigManaging, templateStore: TemplateStoring) {
        _viewModel = StateObject(wrappedValue: ScheduleSummaryViewModel(networking: networking, config: config, templateStore: templateStore))
        self.networking = networking
        self.config = config
        self.templateStore = templateStore
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
                            NavigationLink {
                                EditScheduleView(
                                    networking: networking,
                                    config: config,
                                    schedule: schedule
                                )
                            } label: {
                                ScheduleView(schedule: schedule, includePhaseDetail: true)
                                    .padding(.vertical, 4)
                            }
                        } header: {
                            Text(viewModel.schedulerEnabled ? "active_schedule_title" : "inactive_schedule_title")
                        }
                    } else {
                        NavigationLink {
                            EditScheduleView(
                                networking: networking,
                                config: config,
                                schedule: schedule
                            )
                        } label: {
                            Text("Create a schedule")
                        }
                    }
                }

                ForEach(viewModel.templates) { template in
                    Section {
                        TemplateSummaryListRow(template: template,
                                               networking: networking,
                                               config: config,
                                               templateStore: templateStore,
                                               viewModel: viewModel)
                    } header: {
                        if template == viewModel.templates.first {
                            Text("Templates")
                                .padding(.top, 24)
                        }
                    }
                }

                NavigationLink {
                    ScheduleTemplateListView(networking: networking, templateStore: templateStore, config: config)
                } label: {
                    Text("Manage templates")
                }
                .frame(maxWidth: .infinity)

                FooterSection {
                    Text("templates_not_synced")
                }
            }
        }
        .loadable(viewModel.state, retry: { Task { await viewModel.load() } })
        .alert(alertContent: $viewModel.alertContent)
    }
}

#Preview {
    NavigationStack {
        ScheduleSummaryView(
            networking: NetworkService.preview(),
            config: ConfigManager.preview(),
            templateStore: TemplateStore.preview()
        )
    }
}
