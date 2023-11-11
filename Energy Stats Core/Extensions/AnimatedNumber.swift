//
//  AnimatedNumber.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 10/11/2023.
//

import SwiftUI

public struct AnimatedNumber<T: View>: View {
    let target: Double
    let text: (Double) -> T
    @State private var amount: Double = 0

    public init(target: Double, text: @escaping (Double) -> T) {
        self.target = target
        self.text = text
    }

    public var body: some View {
        text(target)
            .opacity(0)
            .modifier(AnimatableNumberModifier(number: amount, text: text))
            .onAppear { withAnimation(.easeOut(duration: 1.0)) { amount = target }}
    }
}

struct AnimatableNumberModifier<T: View>: AnimatableModifier {
    var number: Double
    let text: (Double) -> T

    var animatableData: Double {
        get { number }
        set { number = newValue }
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                text(number)
            )
    }
}

#Preview {
    AnimatedNumber(target: 60, text: { Text("\(Int($0))") })
}
