//
//  LoadingView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/06/2026.
//

import SwiftUI

public struct LoadingView: View {
    @State private var message: LocalizedStringKey
    private let activity: LoadStateActivity

    public init(message: LoadStateActivity) {
        self.activity = message
        self.message = message.title
    }

    public var body: some View {
        SolarLoadingView(message: message)
            .frame(width: 200, height: 80)
            .task {
                try? await Task.sleep(for: .seconds(10))
                self.message = activity.longOperationTitle
            }
    }
}

#Preview {
    Color.black.overlay(
        ZStack {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                .foregroundStyle(Color.white)

            LoadingView(message: .activating)
        }
    )
    .environment(\.colorScheme, .dark)
    .environment(\.locale, Locale(identifier: "de"))

    Color.white.overlay(
        ZStack {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")

            LoadingView(message: .loading)
        }
    )
    .environment(\.colorScheme, .light)
    .environment(\.locale, Locale(identifier: "de"))
}
