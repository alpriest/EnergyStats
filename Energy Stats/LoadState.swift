//
//  LoadState.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import SwiftUI

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
}

struct LoadStateView: ViewModifier {
    @Binding var loadState: LoadState
    var allowRetry: Bool
    let retry: () -> Void

    func body(content: Content) -> some View {
        switch loadState {
        case .active(let message):
            HStack(spacing: 8) {
                Text(message)
                ProgressView()
            }
        case .error(let error, let reason):
            ErrorAlertView(cause: error, message: reason, allowRetry: allowRetry, retry: retry)
        case .inactive:
            content
        }
    }
}

extension View {
    func loadable(_ state: Binding<LoadState>, allowRetry: Bool = true, retry: @escaping () -> Void) -> some View {
        modifier(LoadStateView(loadState: state, allowRetry: allowRetry, retry: retry))
    }
}

struct LoadState_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text(verbatim: "Hello").loadable(.constant(.active("Loading")), retry: {})
            Text(verbatim: "Hello").loadable(.constant(.error(nil, "Something went wrong")), retry: {})
            Text(verbatim: "Hello").loadable(.constant(.inactive), retry: {})
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
