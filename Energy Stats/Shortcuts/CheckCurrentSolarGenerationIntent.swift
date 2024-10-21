//
//  CheckCurrentSolarGenerationIntent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2024.
//

import AppIntents
import Energy_Stats_Core

struct CheckCurrentSolarGenerationIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Current Solar Generation"
    static var description: IntentDescription? = "Returns the solar being generated in Watts"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ProvidesDialog & ReturnsValue<Int> {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()
        let real = try await services.network.fetchRealData(deviceSN: services.device.deviceSN, variables: ["meterPower2", "pvPower"])
        let currentViewModel = CurrentStatusCalculator(device: services.device,
                                                       response: real,
                                                       config: services.configManager)

        let current = Int(currentViewModel.currentSolarPower * 1000.0)
        return .result(value: current, dialog: IntentDialog(stringLiteral: current.w()))
    }
}
