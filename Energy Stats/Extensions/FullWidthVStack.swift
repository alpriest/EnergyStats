//
//  FullWidthVStack.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/06/2025.
//

import SwiftUI

struct FullWidthVStack<V: View>: View {
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let content: () -> V

    init(
        alignment: HorizontalAlignment = .leading,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> V
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            content()
        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    FullWidthVStack {
        Text("This is some text")
    }.background(Color.red)
}
