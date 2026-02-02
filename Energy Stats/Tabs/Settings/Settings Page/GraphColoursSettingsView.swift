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
            (variable.title(as: .total), variable.colour)
        })

        stats = Dictionary(uniqueKeysWithValues: ReportVariable.allCases.map {
            ($0.titleTotal, $0.colour)
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

                    ColorPickerView(title: key, color: binding)
                }
            } header: {
                Text("Stats")
            }
        }
    }
}

private struct ColorPickerView: View {
    @Binding var color: Color
    @State private var title: String
    @State private var showPicker = false

    init(title: String, color: Binding<Color>) {
        self.title = title
        self._color = color
    }

    private var uiColorBinding: Binding<UIColor> {
        Binding<UIColor>(
            get: {
                UIColor(self.color)
            },
            set: { newUIColor in
                self.color = Color(newUIColor)
            }
        )
    }

    var body: some View {
        HStack {
            GraphVariableColourIndicator(color: color)
            Text(title)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Button {
                showPicker = true
            } label: {
                Text("Change")
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            showPicker = true
        }
        .sheet(isPresented: $showPicker) {
            UIKitColorPicker(color: uiColorBinding) {
                showPicker = false
            }
        }
    }
}

#Preview {
    let vm = GraphColoursSettingsViewModel(configManager: ConfigManager.preview())
    return GraphColoursSettingsView(viewModel: vm)
        .environment(\.locale, .init(identifier: "de"))
}
