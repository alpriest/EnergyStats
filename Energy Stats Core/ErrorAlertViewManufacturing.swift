//
//  ErrorAlertViewManufacturing.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import SwiftUI

public struct ErrorAlertViewOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let checkServerStatus = ErrorAlertViewOptions(rawValue: 1 << 0)
    public static let logoutButton = ErrorAlertViewOptions(rawValue: 1 << 1)
    public static let retry = ErrorAlertViewOptions(rawValue: 1 << 2)
    public static let all: ErrorAlertViewOptions = [.checkServerStatus, .logoutButton, .retry]
}

public protocol ErrorAlertViewManufacturing {
    func make(cause: Error?, message: String, options: ErrorAlertViewOptions, retry: @escaping () -> Void) -> any View
}
