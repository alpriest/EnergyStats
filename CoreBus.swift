//
//  CoreBus.swift
//
//
//  Created by Alistair Priest on 19/09/2025.
//

import Foundation

public enum CoreBus {
    public enum Keys {
        public static let endpoint = "endpoint"
        public static let expected = "expected"
        public static let actual = "actual"
    }

    public static func onUnexpectedServerData(
        api: String,
        expected: String,
        actual: String
    ) {
        let info: [String: String] = [
            Keys.endpoint: api,
            Keys.expected: expected,
            Keys.actual: actual
        ]

        NotificationCenter.default.post(name: .unexpectedServerData, object: nil, userInfo: info)
    }
}
