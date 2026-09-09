//
//  CurrentEnergyStatusIntent.swift
//  Energy Stats
//

import AppIntents
import Energy_Stats_Core
import SwiftUI

@available(iOS 26.0, *)
struct CurrentEnergyStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Energy Status"
    static var description: IntentDescription? = "Shows battery charge, solar generation, house consumption, and grid flow."
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var supportedModes: IntentModes { .background }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetIntent {
        .result(
            dialog: "Here is your current energy status.",
            snippetIntent: CurrentEnergyStatusSnippetIntent()
        )
    }
}

@available(iOS 26.0, *)
private struct CurrentEnergyStatusSnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource = "Current Energy Status"
    static var isDiscoverable: Bool = false
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var supportedModes: IntentModes { .background }

    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()
        let real = try await services.network.fetchRealData(
            deviceSN: services.device.deviceSN,
            variables: [
                "SoC",
                "SoC_1",
                "gridConsumptionPower",
                "generationPower",
                "feedinPower",
                "meterPower2",
                "pvPower"
            ]
        )
        let calculator = CurrentStatusCalculator(
            device: services.device,
            response: real,
            config: services.configManager
        )
        let values = calculator.currentValues()
        let status = CurrentEnergyStatus(
            batteryStateOfCharge: Int(real.datas.SoC()),
            solarGeneration: Int(values.solarPower * 1000.0),
            houseConsumption: Int(values.homeConsumption * 1000.0),
            gridFlow: Int(values.grid * 1000.0)
        )

        return .result(view: CurrentEnergyStatusSnippetView(status: status))
    }
}

@available(iOS 26.0, *)
private struct CurrentEnergyStatus: Sendable {
    let batteryStateOfCharge: Int
    let solarGeneration: Int
    let houseConsumption: Int
    let gridFlow: Int
}

@available(iOS 26.0, *)
private struct CurrentEnergyStatusSnippetView: View {
    let status: CurrentEnergyStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Current Energy Status", systemImage: "bolt.fill")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                statusRow("Battery", value: "\\(status.batteryStateOfCharge)%", systemImage: "battery.75percent")
                statusRow("Solar", value: status.solarGeneration.w(), systemImage: "sun.max.fill")
                statusRow("House", value: status.houseConsumption.w(), systemImage: "house.fill")
                statusRow("Grid", value: gridDescription, systemImage: "transmission")
            }

            Button("Refresh", systemImage: "arrow.clockwise", intent: CurrentEnergyStatusSnippetIntent())
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var gridDescription: String {
        if status.gridFlow < 0 {
            return "\\(abs(status.gridFlow).w()) import"
        } else {
            return "\\(status.gridFlow.w()) export"
        }
    }

    @ViewBuilder
    private func statusRow(_ title: LocalizedStringKey, value: String, systemImage: String) -> some View {
        GridRow {
            Label(title, systemImage: systemImage)
            Text(value)
                .monospacedDigit()
        }
    }
}
