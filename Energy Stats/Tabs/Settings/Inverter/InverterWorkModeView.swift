//
//  InverterWorkModeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import Energy_Stats_Core
import SwiftUI

class InverterWorkModeViewModel: ObservableObject {
    private let networking: FoxESSNetworking
    private let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var items: [SelectableItem<WorkMode>] = []
    @Published var alertContent: AlertContent?

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceID = config.currentDevice.value?.deviceID else { return }
            state = .active("Loading")

            do {
                let response = try await networking.fetchWorkMode(deviceID: deviceID)
                let workMode = response.values.operationModeWorkMode.asWorkMode()
                self.items = WorkMode.allCases.map { SelectableItem($0, isSelected: $0 == workMode) }

                state = .inactive
            } catch {
                state = .error(error, "Could not load work mode")
            }
        }
    }

    func save() {
        guard let mode = selected else { return }

        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceID = config.currentDevice.value?.deviceID else { return }
            state = .active("Saving")

            do {
                try await networking.setWorkMode(deviceID: deviceID, workMode: mode.asInverterWorkMode())
                alertContent = AlertContent(title: "Success", message: "inverter_settings_saved")
                state = .inactive
            } catch {
                state = .error(error, "Could not save work mode")
            }
        }
    }

    func toggle(updating: SelectableItem<WorkMode>) {
        items = items.map { existingVariable in
            var existingVariable = existingVariable

            if existingVariable.id == updating.id {
                existingVariable.setSelected(true)
            } else {
                existingVariable.setSelected(false)
            }

            return existingVariable
        }
    }

    var selected: WorkMode? {
        items.first(where: { $0.isSelected })?.item
    }
}

struct InverterWorkModeView: View {
    @StateObject var viewModel: InverterWorkModeViewModel

    init(networking: FoxESSNetworking, config: ConfigManaging) {
        _viewModel = StateObject(wrappedValue: InverterWorkModeViewModel(networking: networking, config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    List {
                        ForEach(viewModel.items, id: \.self) { item in
                            Button {
                                viewModel.toggle(updating: item)
                            } label: {
                                HStack(alignment: .firstTextBaseline) {
                                    Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                                    VStack(alignment: .leading) {
                                        Text(item.item.title)

                                        OptionalView(item.item.subtitle) {
                                            AnyView($0)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)

                        Text("Inverter change warning")

                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical)
                } footer: {
                    Link(destination: URL(string: "https://github.com/TonyM1958/HA-FoxESS-Modbus/wiki/Inverter-Work-Modes")!) {
                        HStack {
                            Text("Find out more about work modes")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                    }
                }
            }

            BottomButtonsView { viewModel.save() }
        }
        .loadable($viewModel.state) {
            viewModel.load()
        }
        .alert(alertContent: $viewModel.alertContent)
        .navigationTitle("Configure Work Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InverterWorkmodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InverterWorkModeView(networking: DemoNetworking(), config: PreviewConfigManager())
        }
    }
}
