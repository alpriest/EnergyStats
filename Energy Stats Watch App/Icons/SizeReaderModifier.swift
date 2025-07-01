//
//  SizeReaderModifier.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/06/2025.
//

import Energy_Stats_Core
import SwiftUI

struct SizeReaderModifier: ViewModifier {
    let onChange: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        modifier(SizeReaderModifier(onChange: onChange))
    }
}
