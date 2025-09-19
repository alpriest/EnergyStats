//
//  CoreBus.swift
//
//
//  Created by Alistair Priest on 19/09/2025.
//

import Foundation

public enum CoreBus {
    public enum Keys {
        public static let name = "name"
        public static let params = "params"
    }

    public static func onUnexpectedServerData(
        api: String,
        expected: String,
        actual: String
    ) {
        let info: [String: Any] = [
            Keys.name: "unexpected_server_data",
            Keys.params: ["endpoint": api,
                          "expected": expected,
                          "actual": actual]
        ]

        NotificationCenter.default.post(name: .unexpectedServerData, object: nil, userInfo: info)
    }
}
