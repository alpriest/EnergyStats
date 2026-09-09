//
//  ExportParameterDataIntent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/01/2025.
//

import AppIntents
import Energy_Stats_Core
import Foundation
import UniformTypeIdentifiers

struct ExportParameterDataIntent: AppIntent {
    static var title: LocalizedStringResource = "Export parameter data"
    static var description: IntentDescription? = "Exports all parameter data for the specified date using the currently selected parameter group"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .background }

    @Parameter(title: "Date")
    var date: Date

    func perform() async throws -> some ProvidesDialog & ReturnsValue<IntentFile> {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()
        let selectedGraphVariables = self.selectedGraphVariables(configManager: services.configManager)

        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        let raw = try await services.network.fetchHistory(deviceSN: services.device.deviceSN, variables: selectedGraphVariables.map { $0 }, start: startDate, end: endDate)
        let rawData: [ParameterGraphValue] = raw.datas.flatMap { response -> [ParameterGraphValue] in
            guard let rawVariable = services.configManager.variables.first(where: { $0.variable == response.variable }) else { return [] }

            return response.data.compactMap {
                ParameterGraphValue(date: $0.time, value: $0.value, variable: rawVariable)
            }
        }

        let headers = ["Type", "Date", "Value"].lazy.joined(separator: ",")
        let rows = rawData.map {
            [$0.type.name, $0.date.iso8601(), String(describing: $0.value)].lazy.joined(separator: ",")
        }
        let text = ([headers] + rows).joined(separator: "\n")

        let file = IntentFile(
            data: Data(text.utf8),
            filename: "energy-parameters-\(String(date.iso8601().prefix(10))).csv",
            type: .commaSeparatedText
        )
        return .result(value: file, dialog: "Exported parameter data")
    }

    private func selectedGraphVariables(configManager: ConfigManaging) -> [String] {
        if configManager.selectedParameterGraphVariables.count == 0 {
            return ParameterGraphVariableChooserViewModel.DefaultGraphVariables
        } else {
            return configManager.selectedParameterGraphVariables
        }
    }
}
