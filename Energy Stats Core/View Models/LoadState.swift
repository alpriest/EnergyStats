//
//  LoadState.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 30/04/2024.
//

import SwiftUI

public enum LoadStateActivity: LocalizedStringKey {
    case loading = "Loading"
    case saving = "Saving"
    case activating = "Activating"
    case deactivating = "Deactivating"
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
    public let message: LocalizedStringKey

    public init(message: LocalizedStringKey) {
        self.message = message
    }

    public var body: some View {
        SolarLoadingView()
            .frame(width: 200, height: 80)
    }
}

struct SolarLoadingView: View {
    @State private var sunRotation: Double = 0

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
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.white),
                Color(.gray).opacity(0.05)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func sunView() -> some View {
        SunView(solar: 1.0, solarDefinitions: .default, sunSize: 15)
            .rotationEffect(.degrees(sunRotation))
    }

    @ViewBuilder
    private func loadingText() -> some View {
        Text("Loading...")
    }

    @ViewBuilder
    private var border: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
    }

    private func startSunAnimationLoop() {
        // Reset to starting position
        sunRotation = 0

        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            sunRotation = 360
        }
    }
}
