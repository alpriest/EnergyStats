//
//  TipKitManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 24/03/2025.
//

public final class TipKitManager {
    private var config: StoredConfig
    public static var shared = TipKitManager(config: UserDefaultsConfig())

    private init(config: StoredConfig) {
        self.config = config
    }

    public func hasSeen(tip: TipType) -> Bool {
        #if DEBUG
        false
        #else
        config.seenTips.contains { $0 == tip }
        #endif
    }

    public func markAsSeen(tip: TipType) {
        let currentSeenTips = config.seenTips
        config.seenTips = currentSeenTips + [tip]
    }
}
