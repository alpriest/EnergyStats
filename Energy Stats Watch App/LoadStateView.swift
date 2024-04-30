//
//  LoadStateView.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 30/04/2024.
//

import Energy_Stats_Core
import SwiftUI

struct LoadStateView: ViewModifier {
    let loadState: LoadState
    let retry: () -> Void
    let overlay: Bool

    init(loadState: LoadState, retry: @escaping () -> Void, overlay: Bool = false) {
        self.loadState = loadState
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
            Text(reason)
//            ErrorAlertView(cause: error, message: reason, options: options, retry: retry)
        case .inactive:
            content
        }
    }
}

extension View {
    func loadable(_ state: LoadState, overlay: Bool = false, retry: @escaping () -> Void) -> some View {
        modifier(LoadStateView(loadState: state, retry: retry, overlay: overlay))
    }
}

#Preview {
    Text("Hello")
        .loadable(.active("Loading..."), retry: {})
}
