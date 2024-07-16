//
//  ScheduleTemplateListView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/12/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ScheduleTemplateListView: View {
    @StateObject var viewModel: ScheduleTemplateListViewModel
    @State private var selectedTemplateID: String?
    private let config: ConfigManaging
    private let networking: Networking
    private let templateStore: TemplateStoring
    private let modes: [WorkMode] = WorkMode.allCases

    init(networking: Networking, templateStore: TemplateStoring, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: ScheduleTemplateListViewModel(templateStore: templateStore, config: config))
        self.networking = networking
        self.templateStore = templateStore
        self.config = config
    }

    var body: some View {
        Form {
            ForEach(viewModel.templates) { template in
                Section {
                    NavigationLink(destination: {
                        EditTemplateView(networking: networking,
                                         templateStore: templateStore,
                                         config: config,
                                         template: template)
                    }, label: {
                        VStack(alignment: .leading) {
                            Text(template.name)

                            ScheduleView(schedule: template.asSchedule(), includePhaseDetail: true)
                                .padding(.vertical, 4)
                        }
                    })
                } header: {
                    if template == viewModel.templates.first {
                        Text("Templates")
                    }
                }
            }

            Section {
                CreateTemplateButtonView(action: {
                    await viewModel.createTemplate(name: $0)
                })
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear { viewModel.load() }
        .navigationTitle("Templates")
    }
}

#Preview {
    NavigationView {
        ScheduleTemplateListView(
            networking: NetworkService.preview(),
            templateStore: TemplateStore.preview(),
            config: ConfigManager.preview()
        )
    }
}
