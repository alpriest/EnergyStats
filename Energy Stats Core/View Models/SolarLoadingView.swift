//
//  SolarLoadingView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/06/2026.
//

import SwiftUI

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
