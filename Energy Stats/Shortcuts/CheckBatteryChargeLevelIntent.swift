//
//  CheckBatteryChargeLevelIntent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2024.
//

import AppIntents
import Energy_Stats_Core

struct CheckBatteryChargeLevelIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Storage Battery SOC"
    static var description: IntentDescription? = "Returns the battery state of charge as a percentage"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ProvidesDialog & ReturnsValue<Int> {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()
        let real = try await services.network.fetchRealData(deviceSN: services.device.deviceSN, variables: ["SoC", "SoC_1"])
        let soc = Int(real.datas.SoC())

        return .result(value: soc, dialog: IntentDialog(stringLiteral: "\(soc)%"))
    }
}
