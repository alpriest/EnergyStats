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
    @State private var newTemplateName: String = ""
    @State private var createTemplateAlertIsPresented = false
    @State private var isImporting = false
    @State private var isConfirming = false
    @State private var replaceExistingTemplates = false

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
                                         configManager: config,
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

            FooterSection {
                VStack(alignment: .center) {
                    AsyncButton {
                        createTemplateAlertIsPresented.toggle()
                    } label: {
                        Text("Create template")
                    }
                    .buttonStyle(.borderedProminent)
                }.frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .templateAlert(
            configuration: .createTemplate,
            newTemplateName: $newTemplateName,
            isPresented: $createTemplateAlertIsPresented
        ) {
            await viewModel.createTemplate(name: $0)
        }
        .onAppear { viewModel.load() }
        .navigationTitle(.templates)
    }

    @ViewBuilder
    private func exportImportViews() -> some View {
        if let url = viewModel.exportFile?.url {
            ShareLink(item: url) {
                Label("Export templates", systemImage: "square.and.arrow.up")
            }.padding(.top)
        }

        Button {
            isConfirming = true
        } label: {
            Label("Import templates", systemImage: "square.and.arrow.down")
        }.confirmationDialog(
            "Do you want to replace your existing templates with the imported templates?",
            isPresented: $isConfirming,
            titleVisibility: .visible,
            actions: {
                Button("Yes", role: .destructive) {
                    replaceExistingTemplates = true
                    isImporting = true
                }
                Button("No") {
                    replaceExistingTemplates = false
                    isImporting = true
                }
                Button("Cancel", role: .cancel) {
                    isConfirming = false
                }
            }
        )
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) {
            if case let .success(file) = $0 {
                viewModel.importTemplates(
                    from: file,
                    replaceExistingTemplates: replaceExistingTemplates
                )
            }
        }
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
