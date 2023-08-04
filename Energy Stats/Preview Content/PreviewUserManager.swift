//
//  PreviewUserManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/05/2023.
//

import Foundation
import Energy_Stats_Core

extension UserManager {
    static func preview() -> UserManager {
        UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: PreviewConfigManager(), networkCache: InMemoryLoggingNetworkStore())
    }
}

extension DeviceFirmwareVersion {
    static func preview() -> DeviceFirmwareVersion {
        DeviceFirmwareVersion(master: "1.54", slave: "1.01", manager: "1.27")
    }
}
