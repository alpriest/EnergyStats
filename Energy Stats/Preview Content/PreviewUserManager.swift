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
