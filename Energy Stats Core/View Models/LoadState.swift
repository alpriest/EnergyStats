//
//  LoadState.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 30/04/2024.
//

import Combine
import SwiftUI

public enum LoadStateActivity {
    case loading
    case saving
    case activating
    case deactivating
    case loggingOut

    public var title: LocalizedStringKey {
        switch self {
        case .loading: return "Loading"
        case .saving: return "Saving"
        case .activating: return "Activating"
        case .deactivating: return "Deactivating"
        case .loggingOut: return "Logging out"
        }
    }

    public var longOperationTitle: LocalizedStringKey {
        switch self {
        case .loading: return "Still loading"
        case .saving: return "Still saving"
        case .activating: return "Still activating"
        case .deactivating: return "Still deactivating"
        case .loggingOut: return "Still logging out"
        }
    }
}

public enum LoadState: Equatable {
    case inactive
    case active(_ type: LoadStateActivity)
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

    public var isActive: Bool {
        switch self {
        case .active:
            true
        default:
            false
        }
    }
}
