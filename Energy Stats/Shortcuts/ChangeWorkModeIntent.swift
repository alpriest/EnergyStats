//
//  ChangeWorkModeIntent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/07/2025.
//

import AppIntents
import Energy_Stats_Core

struct ChangeWorkModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Change inverter work mode"
    static var description: IntentDescription? = "Changes the work mode of the inverter"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Work mode",
        description: "The mode the inverter should switch to",
        requestValueDialog: IntentDialog("Which work mode would you like to set?")
    )
    var workMode: IntentsWorkMode

    func perform() async throws -> some ReturnsValue<Bool> {
        let services = try ServiceFactory.makeAppIntentInitialisedServices()
        try await services.network.setDeviceSettingsItem(
            deviceSN: services.device.deviceSN,
            item: DeviceSettingsItem.workMode,
            value: workMode.asWorkMode().networkTitle
        )

        return .result(value: true)
    }
}

enum IntentsWorkMode: String, AppEnum, CaseDisplayRepresentable, RawRepresentable {
    case SelfUse
    case FeedIn
    case Backup
    case ForceCharge
    case ForceDischarge

    public static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Work mode")

    public static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .SelfUse: DisplayRepresentation(stringLiteral: "Self Use"),
        .FeedIn: DisplayRepresentation(stringLiteral: "Feed In First"),
        .Backup: DisplayRepresentation(stringLiteral: "Backup"),
        .ForceCharge: DisplayRepresentation(stringLiteral: "Force Charge"),
        .ForceDischarge: DisplayRepresentation(stringLiteral: "Force Discharge")
    ]

    public func asWorkMode() -> WorkMode {
        switch self {
        case .SelfUse:
            return .SelfUse
        case .FeedIn:
            return .Feedin
        case .Backup:
            return .Backup
        case .ForceCharge:
            return .ForceCharge
        case .ForceDischarge:
            return .ForceDischarge
        }
    }
}
