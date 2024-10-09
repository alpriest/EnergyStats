//
//  SolcastErrorAlertViewManufacturing.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2024.
//

import SwiftUI

public class SolcastErrorAlertViewManufacturing: ErrorAlertViewManufacturing {
    public init() {}
    public func make(cause: (any Error)?, message: String, options: ErrorAlertViewOptions, retry: @escaping () -> Void) -> any View {
        SolcastErrorAlertView(cause: cause, message: message, options: options, retry: retry)
    }
}

struct SolcastErrorAlertView: View {
    let cause: Error?
    let message: String
    let options: ErrorAlertViewOptions
    let retry: () -> Void

    var body: some View {
        Text(message)
    }
}
