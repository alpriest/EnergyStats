//
//  LoadState.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/04/2023.
//

import SwiftUI

enum LoadState {
    case inactive
    case active(String)
    case error(String)
}

struct LoadStateView: ViewModifier {
    @Binding var loadState: LoadState

    func body(content: Content) -> some View {
        switch loadState {
        case .active(let message):
            HStack(spacing: 8) {
                Text(message)
                ProgressView()
            }
        case .error(let reason):
            Text(reason)
        case .inactive:
            content
        }
    }
}

extension View {
    func loadable(_ state: Binding<LoadState>) -> some View {
        modifier(LoadStateView(loadState: state))
    }
}

struct LoadState_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello").loadable(.constant(.active("Loading")))
            Text("Hello").loadable(.constant(.error("Something went wrong")))
            Text("Hello").loadable(.constant(.inactive))
        }
    }
}
