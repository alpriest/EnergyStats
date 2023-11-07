//
//  Tintable.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import SwiftUI

struct Tintable: ViewModifier {
    @Binding var isTinted: Bool
    var color: Color

    func body(content: Content) -> some View {
        if isTinted {
            content
                .colorInvert()
                .colorMultiply(color)
        } else {
            content
        }
    }
}

extension View {
    func tinted(enabled: Binding<Bool>, color: Color = .red) -> some View {
        modifier(Tintable(isTinted: enabled, color: color))
    }
}

#Preview {
    VStack {
        Text("hello world")
            .tinted(enabled: .constant(true), color: .green)

        Text("hello world")
            .tinted(enabled: .constant(false), color: .green)
    }
}
