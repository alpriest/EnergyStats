//
//  LoadState.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import Energy_Stats_Core
import SwiftUI

protocol HasLoadState: AnyObject {
    var state: LoadState { get set }
}

extension HasLoadState {
    @MainActor
    func setState(_ state: LoadState) async {
        self.state = state
    }
}

struct LoadStateView: ViewModifier {
    let loadState: LoadState
    var options: ErrorAlertViewOptions
    let retry: () -> Void
    let overlay: Bool
    let errorAlert: ErrorAlertViewManufacturing

    init(
        loadState: LoadState,
        options: ErrorAlertViewOptions,
        errorAlert: ErrorAlertViewManufacturing,
        retry: @escaping () -> Void,
        overlay: Bool = false
    ) {
        self.loadState = loadState
        self.options = options
        self.errorAlert = errorAlert
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
            AnyView(errorAlert.make(cause: error, message: reason, options: options, retry: retry))
        case .inactive:
            content
        }
    }
}

extension View {
    func loadable(
        _ state: LoadState,
        options: ErrorAlertViewOptions = .all,
        errorAlertType: ErrorAlertType = .fox,
        overlay: Bool = false,
        retry: @escaping () -> Void
    ) -> some View {
        modifier(
            LoadStateView(
                loadState: state,
                options: options,
                errorAlert: errorAlertType == .fox ? FoxErrorAlertViewManufacturing() : SolcastErrorAlertViewManufacturing(),
                retry: retry,
                overlay: overlay
            )
        )
    }
}

struct LoadState_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text(verbatim: "Hello world how are you").loadable(.active(.loading), overlay: true, retry: {})
            Text(verbatim: "Hello").loadable(.error(nil, "Something went wrong"), retry: {})
            Text(verbatim: "Hello").loadable(.inactive, retry: {})
        }
        .environment(\.locale, .init(identifier: "de"))
    }
}
