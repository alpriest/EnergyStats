//
//  CheckInverterStatusIntent.swift
//  Energy Stats
//

import AppIntents
import Energy_Stats_Core

struct CheckInverterStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Inverter Status"
    static var description: IntentDescription? = "Returns whether the inverter is ONLINE or OFFLINE."
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .background }

    func perform() async throws -> some ProvidesDialog & ReturnsValue<String> {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()
        let response = try await services.network.fetchDevice(deviceSN: services.device.deviceSN)
        let state = DeviceState(rawValue: response.status) ?? .offline
        let status = state == .online ? "ONLINE" : "OFFLINE"

        return .result(
            value: status,
            dialog: IntentDialog(stringLiteral: status)
        )
    }
}
