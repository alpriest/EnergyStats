//
//  LoadState.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 30/04/2024.
//

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

struct SolarLoadingView: View {
    @State private var sunRotation: Double = 0
    let message: LocalizedStringKey

    var body: some View {
        ZStack {
            backgroundGradient
            HStack {
                sunView()
                    .frame(width: 34)
                loadingText()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(border)
        .onAppear {
            startSunAnimationLoop()
        }
    }

    // MARK: - View Components

    @ViewBuilder
    private var backgroundGradient: some View {
        Color(.loadingBackground).ignoresSafeArea()
    }

    @ViewBuilder
    private func sunView() -> some View {
        SunView(solar: 1.0, solarDefinitions: .default, sunSize: 15)
            .rotationEffect(.degrees(sunRotation))
    }

    @ViewBuilder
    private func loadingText() -> some View {
        Text(message)
    }

    @ViewBuilder
    private var border: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color.primary.opacity(0.65), lineWidth: 1)
    }

    private func startSunAnimationLoop() {
        // Reset to starting position
        sunRotation = 0

        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            sunRotation = 360
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
