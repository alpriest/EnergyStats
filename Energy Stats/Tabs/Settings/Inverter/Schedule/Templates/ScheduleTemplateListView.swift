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
    @State private var newTemplateName: String = ""
    @State private var newTemplateDescription: String = ""
    private let config: ConfigManaging
    private let networking: Networking
    private let modes: [SchedulerModeResponse]

    init(networking: Networking, config: ConfigManaging, modes: [SchedulerModeResponse]) {
        _viewModel = StateObject(wrappedValue: ScheduleTemplateListViewModel(networking: networking, config: config))
        self.networking = networking
        self.config = config
        self.modes = modes
    }

    var body: some View {
        Form {
            Section {
                ForEach(viewModel.templates) { template in
                    NavigationLink(destination: {
                        EditTemplateView(networking: networking,
                                         config: config,
                                         templateID: template.id,
                                         modes: modes)
                    }, label: {
                        Text(template.name)
                    })
                }
            } header: {
                Text("Templates")
            }

            Section {
                TextField("Name", text: $newTemplateName)
                TextField("Description", text: $newTemplateDescription)

            } header: {
                Text("New template")
            } footer: {
                Button {
                    Task {
                        await viewModel.createTemplate(name: newTemplateName, description: newTemplateDescription)
                        newTemplateName = ""
                        newTemplateDescription = ""
                    }
                } label: {
                    Text("Create new template")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
        }
        .onAppear { Task { await viewModel.load() } }
        .navigationTitle("Templates")
    }
}

#Preview {
    NavigationView {
        ScheduleTemplateListView(
            networking: DemoNetworking(),
            config: PreviewConfigManager(),
            modes: SchedulerModeResponse.preview()
        )
    }
}
