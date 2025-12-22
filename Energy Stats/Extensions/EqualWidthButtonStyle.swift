//
//  EqualWidthButtonStyle.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/12/2025.
//


import Energy_Stats_Core
import SwiftUI

struct EqualWidthButtonStyle: ButtonStyle {
    @Binding var buttonWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(rectReader($buttonWidth))
            .frame(minWidth: buttonWidth)
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(colorScheme == .dark ? Color.white.opacity(0.14) : Color.paleGray)
            .foregroundStyle(Color.accentColor)
            .cornerRadius(6)
    }

    private func rectReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { gr -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = max(binding.wrappedValue, gr.frame(in: .local).width)
            }
            return Color.clear
        }
    }
}