//
//  PVOutputSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 18/02/2026.
//

import Energy_Stats_Core
import SwiftUI

struct PVOutputSettingsViewData: Copiable, Equatable {
    var apiKey: String
    var systemId: String
    var startDate: Date
    var endDate: Date
    var validCredentials: Bool

    func create(copying previous: PVOutputSettingsViewData) -> PVOutputSettingsViewData {
        PVOutputSettingsViewData(
            apiKey: previous.apiKey,
            systemId: previous.systemId,
            startDate: previous.startDate,
            endDate: previous.endDate,
            validCredentials: previous.validCredentials
        )
    }

    static var initial: PVOutputSettingsViewData {
        PVOutputSettingsViewData(
            apiKey: "",
            systemId: "",
            startDate: .yesterday(),
            endDate: .now,
            validCredentials: false
        )
    }
}

struct PVOutputSettingsView: View {
    @StateObject var viewModel: PVOutputSettingsViewModel

    init(configManager: ConfigManaging, foxService: Networking, pvOutputService: PVOutputServicing) {
        _viewModel = .init(wrappedValue: PVOutputSettingsViewModel(configManager: configManager, foxService: foxService, pvOutputService: pvOutputService))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(content: {
                    Text("PVOutput_description")
                }, footer: {
                    FindOutMoreView(url: URL(string: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/PV-Output")!)
                })

                Group {
                    if viewModel.viewData.validCredentials {
                        exportChoices()
                    }

                    credentials()
                }
            }
        }
        .navigationTitle(.pvOutput)
        .alert(alertContent: $viewModel.alertContent)
    }

    private func credentials() -> some View {
        Section {
            SecureField("API Key", text: $viewModel.viewData.apiKey)
            TextField("System ID", text: $viewModel.viewData.systemId)
            
            if viewModel.viewData.validCredentials {
                ExternalWebNavigationLink(url: "https://pvoutput.org/list.jsp?sid=\(viewModel.viewData.systemId)") {
                    Text("View your data on https://pvoutput.org")
                }
            }

            HStack {
                Button(action: { Task { await viewModel.verifyCredentials() }}) {
                    Text("Save credentials")
                }.buttonStyle(.borderedProminent)

                Button { viewModel.clearCredentials() } label: {
                    Text("Delete credentials")
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.viewData.validCredentials)
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        }
    }

    private func exportChoices() -> some View {
        Section {
            DatePicker("Choose single date", selection: $viewModel.viewData.startDate, displayedComponents: .date)

            HStack {
                Button(action: { Task { await viewModel.upload() }}) {
                    Text("Upload to PVOutput")
                }.buttonStyle(.borderedProminent)
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    PVOutputSettingsView(
        configManager: ConfigManager.preview(),
        foxService: NetworkService.preview(),
        pvOutputService: PVOutputService.preview()
    )
}
