//
//  ActiveScheduleIntent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 25/11/2024.
//

import AppIntents
import Energy_Stats_Core

struct ActiveScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Activate inverter mode schedule"
    static var description: IntentDescription? = "Activates the named inverter mode schedule"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Template name")
    var template: String

    func perform() async throws -> some ProvidesDialog & ReturnsValue<Bool> {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()
        if let schedule = services.configManager.scheduleTemplates.first(where: { $0.name.lowercased() == template.lowercased() }) {
            do {
                try await services.network.saveSchedule(deviceSN: services.device.deviceSN, schedule: schedule.asSchedule())

                return .result(value: true, dialog: IntentDialog(stringLiteral: "Template \(template) activated"))
            } catch {
                return .result(value: false, dialog: IntentDialog(stringLiteral: "Failed to activate template named \(template)"))
            }
        } else {
            return .result(value: false, dialog: IntentDialog(stringLiteral: "Failed to find template named \(template)"))
        }
    }
}
