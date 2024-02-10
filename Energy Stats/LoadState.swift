//
//  LoadState.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import SwiftUI

protocol HasLoadState: AnyObject {
    var state: LoadState { get set }
}

extension HasLoadState {
    func setState(_ state: LoadState) {
        Task { @MainActor in
            self.state = state
        }
    }
}

enum LoadState: Equatable {
    case inactive
    case active(LocalizedStringKey)
    case error(Error?, String)

    static func ==(lhs: LoadState, rhs: LoadState) -> Bool {
        switch (lhs, rhs) {
        case (.inactive, .inactive):
            return true
        case (.active, .active):
            return true
        case (.error, .error):
            return true
        default:
            return true
        }
    }

    func opacity() -> Double {
        switch self {
        case .active:
            1.0
        default:
            0.0
        }
    }
}

struct LoadingView: View {
    let message: LocalizedStringKey

    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
            Text(message)
        }
        .padding()
        .border(Color.black)
        .background(Color.white)
    }
}

struct LoadStateView: ViewModifier {
    let loadState: LoadState
    var allowRetry: Bool
    let retry: () -> Void
    let overlay: Bool

    init(loadState: LoadState, allowRetry: Bool, retry: @escaping () -> Void, overlay: Bool = false) {
        self.loadState = loadState
        self.allowRetry = allowRetry
        self.retry = retry
        self.overlay = overlay
    }

    func body(content: Content) -> some View {
        switch loadState {
        case .active(let message):
            if overlay {
                ZStack {
                    content
                    LoadingView(message: message)
                }
            } else {
                LoadingView(message: message)
            }
        case .error(let error, let reason):
            ErrorAlertView(cause: error, message: reason, allowRetry: allowRetry, retry: retry)
        case .inactive:
            content
        }
    }
}

extension View {
    func loadable(_ state: LoadState, allowRetry: Bool = true, overlay: Bool = false, retry: @escaping () -> Void) -> some View {
        modifier(LoadStateView(loadState: state, allowRetry: allowRetry, retry: retry, overlay: overlay))
    }
}

struct LoadState_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text(verbatim: "Hello world how are you").loadable(.active("Loading"), overlay: true, retry: {})
            Text(verbatim: "Hello").loadable(.error(nil, "Something went wrong"), retry: {})
            Text(verbatim: "Hello").loadable(.inactive, retry: {})
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
