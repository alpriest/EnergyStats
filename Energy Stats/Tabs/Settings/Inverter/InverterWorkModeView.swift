//
//  InverterWorkModeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/08/2023.
//

import Energy_Stats_Core
import SwiftUI

class InverterWorkModeViewModel: ObservableObject {
    private let networking: Networking
    private let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var items: [SelectableItem<WorkMode>] = []

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceID = config.currentDevice.value?.deviceID else { return }
            state = .active(String(key: .loading))

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

    func save() async -> Bool {
        guard let mode = selected else { return false }

        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceID = config.currentDevice.value?.deviceID else { return }

            do {
                try await networking.setWorkMode(deviceID: deviceID, workMode: mode.asInverterWorkMode())
                state = .inactive
            } catch {
                state = .error(error, "Could not save work mode")
            }
        }
        return true
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
    @Environment(\.dismiss) var dismiss

    init(networking: Networking, config: ConfigManaging) {
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

                        Text("Only change these values if you know what you are doing")

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

            VStack(spacing: 0) {
                Color("BottomBarDivider")
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("cancel")

                    Button(action: {
                        Task {
                            if await viewModel.save() {
                                dismiss()
                            }
                        }
                    }) {
                        Text("Apply")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Configure Work Mode")
        .navigationBarTitleDisplayMode(.inline)
        .loadable($viewModel.state) {
            viewModel.load()
        }
    }
}

struct InverterWorkmodeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InverterWorkModeView(networking: DemoNetworking(), config: PreviewConfigManager())
        }
    }
}
