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
                                ScheduleView(schedule: schedule)
                                    .padding(.vertical, 4)
                            }
                        } header: {
                            Text("active_schedule_title")
                        }
                    } else {
                        NavigationLink(value: schedule) {
                            Text("Create a schedule")
                        }
                    }
                }

                Section {
                    ForEach(viewModel.templates) {
                        TemplateSummaryListRow(template: $0,
                                               networking: networking,
                                               config: config,
                                               templateStore: templateStore,
                                               viewModel: viewModel)
                    }
                } header: {
                    Text("Templates")
                        .padding(.top, 24)
                } footer: {
                    VStack {
                        NavigationLink {
                            ScheduleTemplateListView(networking: networking, templateStore: templateStore, config: config)
                        } label: {
                            Text("Manage templates")
                        }.buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                }

                FooterSection {
                    Text("templates_not_synced")
                }
            }
        }
        .loadable(viewModel.state, retry: { Task { await viewModel.load() } })
        .alert(alertContent: $viewModel.alertContent)
    }
}

struct TemplateSummaryListRow: View {
    @State private var isActive: Bool = false
    let template: ScheduleTemplate
    let networking: Networking
    let config: ConfigManaging
    let templateStore: TemplateStoring
    @ObservedObject var viewModel: ScheduleSummaryViewModel

    var body: some View {
        HStack {
            Text(template.name)

            Spacer()

            Button {
                isActive = true
            } label: {
                Text("Edit")
            }
            .buttonStyle(.borderedProminent)
            .navigationDestination(isPresented: $isActive, destination: {
                EditTemplateView(
                    networking: networking,
                    templateStore: templateStore,
                    config: config,
                    template: template
                )
            })

            Button {
                Task { await viewModel.activate(template) }
            } label: {
                Text("Activate")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NavigationStack {
        ScheduleSummaryView(
            networking: DemoNetworking(),
            config: PreviewConfigManager(),
            templateStore: PreviewTemplateStore()
        )
    }
}
