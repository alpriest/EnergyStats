//
//  AlertContent.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 08/08/2023.
//

import SwiftUI

public struct AlertContent {
    public let title: LocalizedStringKey?
    public let message: LocalizedStringKey
    public let onDismiss: () -> Void

    public init(title: LocalizedStringKey?, message: LocalizedStringKey, onDismiss: @escaping (() -> Void) = {}) {
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
    }
}
