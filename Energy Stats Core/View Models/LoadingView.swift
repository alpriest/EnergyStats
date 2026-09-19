//
//  LoadingView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/06/2026.
//

import SwiftUI

public struct LoadingView: View {
    private let activity: LoadStateActivity
    private let id: AnyHashable

    public init(message: LoadStateActivity, id: AnyHashable? = nil) {
        self.activity = message
        self.id = activity
    }

    public var body: some View {
        TimedLoadingView(activity: activity)
            .id(id)
    }
}

private struct TimedLoadingView: View {
    @State private var isLongOperation = false
    let activity: LoadStateActivity

    var body: some View {
        SolarLoadingView(
            message: isLongOperation ? activity.longOperationTitle : activity.title
        )
            .frame(width: 200, height: 80)
            .task {
                isLongOperation = false

                do {
                    try await Task.sleep(for: .seconds(5))
                } catch {
                    return
                }

                guard !Task.isCancelled else {
                    return
                }

                isLongOperation = true
            }
            .onDisappear {
                isLongOperation = false
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
