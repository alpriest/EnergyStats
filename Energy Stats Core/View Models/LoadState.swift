//
//  LoadState.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 30/04/2024.
//

import SwiftUI

public enum LoadState: Equatable {
    case inactive
    case active(LocalizedStringKey)
    case error(Error?, String)

    public static func ==(lhs: LoadState, rhs: LoadState) -> Bool {
        switch (lhs, rhs) {
        case (.inactive, .inactive):
            return true
        case (.active, .active):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }

    public func opacity() -> Double {
        switch self {
        case .active:
            1.0
        default:
            0.0
        }
    }

    public var isError: Bool {
        switch self {
        case .error:
            true
        default:
            false
        }
    }
}

public struct LoadingView: View {
    public let message: LocalizedStringKey

    public init(message: LocalizedStringKey) {
        self.message = message
    }

    public var body: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text(message)
        }
        .padding()
        .border(Color("pale_gray"))
        .background(Color.background)
    }
}
