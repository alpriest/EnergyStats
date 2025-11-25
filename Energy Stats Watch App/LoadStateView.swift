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
        case .error(_, let reason):
            Text(reason)
        case .inactive:
            content
        }
    }
}

struct LoadingView: View {
    public let message: LoadStateActivity

    public init(message: LoadStateActivity) {
        self.message = message
    }

    public var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .frame(width: 14, height: 14)
            Text(message.title)
        }
        .padding()
        .border(Color("pale_gray", bundle: Bundle(for: BundleLocator.self)))
        .background(Color.black)
        .shadow(color: Color.black, radius: 10)
        .transition(.opacity)
    }
}

extension View {
    func loadable(_ state: LoadState, overlay: Bool = false, retry: @escaping () -> Void) -> some View {
        modifier(LoadStateView(loadState: state, retry: retry, overlay: overlay))
    }
}

#Preview {
    Text(verbatim: "Hello")
        .loadable(.active(.loading), retry: {})
}
