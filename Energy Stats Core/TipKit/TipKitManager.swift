//
//  TipKitManager.swift
//  Energy Stats
//
//  Created by Alistair Priest on 24/03/2025.
//

public final class TipKitManager {
    private var config: Config
    public static var shared = TipKitManager(config: UserDefaultsConfig())

    private init(config: Config) {
        self.config = config
    }

    public func hasSeen(tip: TipType) -> Bool {
        config.seenTips.contains { $0 == tip }
    }

    public func markAsSeen(tip: TipType) {
        let currentSeenTips = config.seenTips
        config.seenTips = currentSeenTips + [tip]
    }
}
