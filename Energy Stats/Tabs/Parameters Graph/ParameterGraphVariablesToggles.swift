//
//  ParameterGraphVariablesToggles.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/05/2023.
//

import Energy_Stats_Core
import SwiftUI

struct ParameterGraphVariablesToggles: View {
    @ObservedObject private var viewModel: ParametersGraphTabViewModel
    @Binding private var selectedDate: Date?
    @Binding private var valuesAtTime: ValuesAtTime<ParameterGraphValue>?
    private let appSettings: AppSettings
    private let filter: String?

    init(
        viewModel: ParametersGraphTabViewModel,
        selectedDate: Binding<Date?>,
        valuesAtTime: Binding<ValuesAtTime<ParameterGraphValue>?>,
        appSettings: AppSettings,
        filter: String? = nil
    ) {
        self.viewModel = viewModel
        self._selectedDate = selectedDate
        self._valuesAtTime = valuesAtTime
        self.appSettings = appSettings
        self.filter = filter
    }

    private var graphVariables: [ParameterGraphVariable] {
        viewModel.graphVariables.filter { filter == nil || $0.type.unit == filter }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(graphVariables, id: \.self) { variable in
                if variable.isSelected {
                    HStack {
                        row(variable)
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }.onChange(of: viewModel.graphVariables) { _ in
            viewModel.refresh()
        }
    }

    @ViewBuilder
    private func row(_ variable: ParameterGraphVariable) -> some View {
        Button(action: { viewModel.toggle(visibilityOf: variable) }) {
            let title = variable.type.title(as: .snapshot)

            AStack {
                VStack(alignment: .leading) {
                    HStack {
                        GraphVariableColourIndicator(color: variable.type.colour)
                            .padding(.top, 3)

                        Text(title)
                    }

                    if let description = variable.type.description, title != description, appSettings.showGraphValueDescriptions {
                        Text(description)
                            .font(.system(size: 10))
                            .foregroundColor(Color("text_dimmed"))
                            .padding(.leading, 23)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                Spacer()

                HStack {
                    if let valuesAtTime, let graphValue = valuesAtTime.values.first(where: { $0.type == variable.type }) {
                        VStack {
                            Text(graphValue.formatted())
                            Text(" ")
                                .font(.system(size: 8.0))
                        }
                    } else if let bounds = viewModel.graphVariableBounds.first(where: { $0.type == variable.type }) {
                        ValueBoundsView(value: bounds.min, type: .min, decimalPlaces: appSettings.decimalPlaces)
                        ValueBoundsView(value: bounds.max, type: .max, decimalPlaces: appSettings.decimalPlaces)
                        ValueBoundsView(value: bounds.now, type: .now, decimalPlaces: appSettings.decimalPlaces)
                    }
                }
            }
            .opacity(variable.enabled ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG

#Preview {
    ParameterGraphVariablesToggles(
        viewModel: ParametersGraphTabViewModel(
            networking: NetworkService.preview(),
            configManager: ConfigManager.preview(),
            solarForecastProvider: { PreviewSolcast() }
        ),
        selectedDate: .constant(nil),
        valuesAtTime: .constant(nil),
        appSettings: .mock(),
        filter: nil
    )
}
#endif
