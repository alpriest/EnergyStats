//
//  ExportStatsDataIntent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/01/2025.
//

import AppIntents
import Energy_Stats_Core
import Foundation
import UniformTypeIdentifiers

struct ExportStatsDataIntent: AppIntent {
    static var title: LocalizedStringResource = "Export stats day data"
    static var description: IntentDescription? = "Exports stats data for the specified date that you would usually see on the stats page"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .background }

    @Parameter(title: "Date")
    var date: Date

    func perform() async throws -> some ProvidesDialog & ReturnsValue<IntentFile> {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()

        let rawData = try await services.network.fetchReport(
            deviceSN: services.device.deviceSN,
            variables: [.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads, .pvEnergyTotal],
            queryDate: QueryDate(from: date),
            reportType: .day
        )

        let headers = ["Type", "Hour", "Value"].lazy.joined(separator: ",")
        let rows = rawData.flatMap { variableReport in
            variableReport.values.map {
                [
                    variableReport.variable,
                    String(describing: $0.index),
                    String(describing: $0.value),
                ].lazy.joined(separator: ",")
            }
        }
        let text = ([headers] + rows).joined(separator: "\n")

        let file = IntentFile(
            data: Data(text.utf8),
            filename: "energy-stats-\(String(date.iso8601().prefix(10))).csv",
            type: .commaSeparatedText
        )
        return .result(value: file, dialog: "Exported stats data")
    }
}
