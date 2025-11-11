//
//  GraphColoursSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/11/2025.
//

import Energy_Stats_Core
import SwiftUI

class GraphColoursSettingsViewModel: ObservableObject {
    @Published var parameters: [String: Color] = [:]
    @Published var stats: [String: Color] = [:]

    init(configManager: ConfigManaging) {
        parameters = Dictionary(uniqueKeysWithValues: configManager.variables.map { variable in
            (variable.name, variable.colour)
        })

        stats = Dictionary(uniqueKeysWithValues: ReportVariable.allCases.map {
            ($0.title, $0.colour)
        })
    }
}

struct GraphColoursSettingsView: View {
    @ObservedObject var viewModel: GraphColoursSettingsViewModel

    var body: some View {
        Form {
            Section {
                ForEach(viewModel.stats.keys.sorted(), id: \.self) { key in
                    let binding = Binding<Color>(
                        get: { viewModel.stats[key] ?? .accentColor },
                        set: { newValue in viewModel.stats[key] = newValue }
                    )

                    HStack {
                        Text(key)
                        Spacer()
                        ColorPicker(key, selection: binding)
                            .labelsHidden()
                    }
                }
            } header: {
                Text("Stats")
            }

            Section {
                ForEach(viewModel.parameters.keys.sorted(), id: \.self) { key in
                    let binding = Binding<Color>(
                        get: { viewModel.parameters[key] ?? .accentColor },
                        set: { newValue in viewModel.parameters[key] = newValue }
                    )

                    HStack {
                        Text(key)
                        Spacer()
                        ColorPicker(key, selection: binding)
                            .labelsHidden()
                    }
                }
            } header: {
                Text("Parameters")
            }
        }
    }
}

#Preview {
    let vm = GraphColoursSettingsViewModel(configManager: ConfigManager.preview())
    return GraphColoursSettingsView(viewModel: vm)
}
