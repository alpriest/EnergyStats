//
//  StatsGraphVariableToggles.swift
//  Energy Stats
//
//  Created by Alistair Priest on 16/05/2023.
//

import Energy_Stats_Core
import SwiftUI

struct StatsGraphVariableToggles: View {
    @ObservedObject var viewModel: StatsTabViewModel
    @Binding var selectedDate: Date?
    @Binding var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    let appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.graphVariables, id: \.self) { variable in
                HStack {
                    row(variable) {
                        HStack(alignment: .top) {
                            Circle()
                                .foregroundColor(variable.type.colour)
                                .frame(width: 15, height: 15)
                                .padding(.top, 5)

                            VStack(alignment: .leading) {
                                Text(variable.type.title)

                                if variable.type.title != variable.type.description, appSettings.showGraphValueDescriptions {
                                    Text(variable.type.description)
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("text_dimmed"))
                                }
                            }

                            Spacer()

                            if let valuesAtTime, let graphValue = valuesAtTime.values.first(where: { $0.type == variable.type }) {
                                Text(graphValue.formatted(appSettings.decimalPlaces))
                                    .monospacedDigit()
                            } else {
                                OptionalView(viewModel.total(of: variable.type)) {
                                    EnergyText(amount: $0, appSettings: appSettings, type: .default)
                                }
                            }
                        }
                        .opacity(variable.enabled ? 1.0 : 0.5)
                    }
                }
                .listRowSeparator(.hidden)
            }

        }.onChange(of: viewModel.graphVariables) { _ in
            viewModel.refresh()
        }
    }

    @ViewBuilder
    private func row(_ variable: StatsGraphVariable, _ content: () -> some View) -> some View {
        if #available(iOS 16.0, *) {
            Button(action: { viewModel.toggle(visibilityOf: variable) }) {
                content()
            }
            .buttonStyle(.plain)
        } else {
            content()
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
struct StatsGraphVariableToggles_Previews: PreviewProvider {
    static var previews: some View {
        StatsGraphVariableToggles(
            viewModel: StatsTabViewModel(networking: DemoNetworking(), configManager: ConfigManager.preview()),
            selectedDate: .constant(nil),
            valuesAtTime: .constant(nil),
            appSettings: .mock()
        )
    }
}
#endif
