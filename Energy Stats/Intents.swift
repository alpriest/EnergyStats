//
//  Intents.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/08/2023.
//

import AppIntents
import Energy_Stats_Core
import Foundation

@available(iOS 16.0, *)
struct CheckBatteryChargeLevelIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Storage Battery SOC"
    static var description: IntentDescription? = "Returns the battery state of charge as a percentage"
    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some ProvidesDialog & ReturnsValue<Int> {
        let store = KeychainStore()
        let config = UserDefaultsConfig()
        let network = NetworkService.standard(keychainStore: store, config: config)
        guard let deviceSN = config.selectedDeviceSN else {
            throw ConfigManager.NoDeviceFoundError()
        }
        let real = try await network.fetchRealData(deviceSN: deviceSN, variables: ["SoC", "SoC_1"])
        let soc = Int(real.datas.SoC() ?? 0)

        return .result(value: soc, dialog: IntentDialog(stringLiteral: "\(soc)%"))
    }
}

//@available(iOS 16.0, *)
//enum IntentsWorkMode: String, AppEnum, CaseDisplayRepresentable, RawRepresentable {
//    case selfUse
//    case feedInFirst
//    case backup
//    case powerStation
//    case peakShaving
//
//    public static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Work mode")
//
//    public static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
//        .selfUse: DisplayRepresentation(title: "Self Use"),
//        .feedInFirst: DisplayRepresentation(title: "Feed In First"),
//        .backup: DisplayRepresentation(title: "Backup"),
//        .powerStation: DisplayRepresentation(title: "Power Station"),
//        .peakShaving: DisplayRepresentation(title: "Peak Shaving")
//    ]
//
//    public func asInverterWorkMode() -> InverterWorkMode {
//        switch self {
//        case .selfUse:
//            return .selfUse
//        case .feedInFirst:
//            return .feedInFirst
//        case .backup:
//            return .backup
//        case .powerStation:
//            return .powerStation
//        case .peakShaving:
//            return .peakShaving
//        }
//    }
//}

//@available(iOS 16.0, *)
//struct ChangeWorkModeIntent: AppIntent {
//    static var title: LocalizedStringResource = "Change inverter work mode"
//    static var description: IntentDescription? = "Changes the work mode of the inverter"
//    static var authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication
//    static var openAppWhenRun: Bool = false
//
//    @Parameter(
//        title: "Work mode",
//        description: "The workmode to change the inverter to",
//        requestValueDialog: IntentDialog("Which work mode would you like to set?")
//    )
//    var workMode: IntentsWorkMode
//
//    func perform() async throws -> some ReturnsValue<Bool> {
//        let store = KeychainStore()
//        let network = Network(credentials: store, store: InMemoryLoggingNetworkStore())
//        let config = UserDefaultsConfig()
//        guard let deviceID = config.selectedDeviceSN else {
//            throw ConfigManager.NoDeviceFoundError()
//        }
//        try await network.setWorkMode(deviceID: deviceID, workMode: workMode.asInverterWorkMode())
//
//        return .result(value: true)
//    }
//}

@available(iOS 16.0, *)
struct EnergyStatsShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckBatteryChargeLevelIntent(),
            phrases: ["Check my storage battery SOC on \(.applicationName)"],
            shortTitle: "Storage Battery SOC"
        )
    }
}
