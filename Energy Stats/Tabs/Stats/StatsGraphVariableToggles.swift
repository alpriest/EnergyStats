//
//  StatsGraphVariableToggles.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/05/2023.
//

import Energy_Stats_Core
import SwiftUI

struct AStack<T: View>: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    private let content: T
    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment

    init(horizontalAlignment: HorizontalAlignment = .leading, verticalAlignment: VerticalAlignment = .top, @ViewBuilder _ content: () -> T) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.content = content()
    }

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: horizontalAlignment) {
                content
            }
        } else {
            HStack(alignment: verticalAlignment) {
                content
            }
        }
    }
}

struct StatsGraphVariableToggles: View {
    @ObservedObject var viewModel: StatsTabViewModel
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    let appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.graphVariables, id: \.self) { variable in
                HStack {
                    row(variable)
                }
                .listRowSeparator(.hidden)
            }

        }.onChange(of: viewModel.graphVariables) { _ in
            viewModel.refresh()
        }
    }

    @ViewBuilder
    private func row(_ variable: StatsGraphVariable) -> some View {
        Button(action: { viewModel.toggle(visibilityOf: variable) }) {
            AStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Circle()
                            .foregroundColor(variable.type.colour)
                            .frame(width: 15, height: 15)
                            .padding(.top, 3)

                        Text(variable.type.title)
                    }

                    if variable.type.title != variable.type.description, appSettings.showGraphValueDescriptions {
                        Text(variable.type.description)
                            .font(.caption)
                            .foregroundColor(Color("text_dimmed"))
                            .padding(.leading, 23)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                Spacer()

                VStack {
                    if let valuesAtTime, let graphValue = valuesAtTime.values.first(where: { $0.type == variable.type }) {
                        Text(graphValue.formatted(1))
                            .monospacedDigit()
                    } else {
                        OptionalView(viewModel.total(of: variable.type)) {
                            EnergyText(amount: $0, appSettings: appSettings, type: .default, decimalPlaceOverride: 1)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .opacity(variable.enabled ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct StatsGraphVariableToggles_Previews: PreviewProvider {
    static var previews: some View {
        StatsGraphVariableToggles(
            viewModel: StatsTabViewModel(
                networking: NetworkService.preview(),
                configManager: ConfigManager.preview()
            ),
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil),
            appSettings: .mock()
        )
    }
}
#endif
