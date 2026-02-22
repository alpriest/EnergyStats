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

enum DateMode {
    case single
    case range
}

struct PVOutputSettingsView: View {
    @StateObject var viewModel: PVOutputSettingsViewModel
    @State private var dateMode: DateMode = .single

    init(configManager: ConfigManaging, pvOutputService: PVOutputServicing) {
        _viewModel = .init(wrappedValue: PVOutputSettingsViewModel(configManager: configManager, pvOutputService: pvOutputService))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Text("PVOutput_description")
                }

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

            HStack {
                Button(action: { Task { await viewModel.verifyCredentials() }}) {
                    Text("Save credentials")
                }.buttonStyle(.borderedProminent)

                if viewModel.viewData.validCredentials {
                    Button { viewModel.clearCredentials() } label: {
                        Text("Delete credentials")
                    }
                }
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        }
    }

    private func exportChoices() -> some View {
        Section {
            Picker(selection: $dateMode) {
                Text("Single").tag(DateMode.single)
                Text("Range").tag(DateMode.range)
            } label: {
                Text("Date mode")
            }.pickerStyle(.segmented)

            switch dateMode {
            case .single:
                DatePicker("Choose single date", selection: $viewModel.viewData.startDate, displayedComponents: .date)
            case .range:
                VStack {
                    DatePicker("Choose start date", selection: $viewModel.viewData.startDate, displayedComponents: .date)

                    DatePicker("Choose end date", selection: $viewModel.viewData.endDate, displayedComponents: .date)
                }
            }

            HStack {
                Button(action: {}) {
                    Text("Upload to PVOutput")
                }.buttonStyle(.borderedProminent)
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    PVOutputSettingsView(configManager: ConfigManager.preview(), pvOutputService: PVOutputService.preview())
}
