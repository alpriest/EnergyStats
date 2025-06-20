//
//  StepView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/06/2025.
//

import SwiftUI

enum StepViewStyle {
    case circle(_ count: Int)
    case custom(_ iconName: String, _ color: Color)

    var icon: String {
        switch self {
        case .circle:
            "circle.fill"
        case .custom(let iconName, _):
            iconName
        }
    }

    var overlay: String? {
        switch self {
        case .circle(let count):
            String(count)
        case .custom:
            nil
        }
    }

    var color: Color {
        switch self {
        case .circle:
            Color.yellow.opacity(0.7)
        case .custom(_, let color):
            color
        }
    }
}

struct StepView: View {
    private let text: LocalizedStringKey
    private let style: StepViewStyle

    init(text: LocalizedStringKey, style: StepViewStyle) {
        self.text = text
        self.style = style
    }

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: style.icon)
                .foregroundStyle(style.color)
                .ifLet(style.overlay) {
                    $0.overlay(
                        Text($1)
                            .font(.caption)
                    )
                }
                .frame(width: 18)
                .padding(.top, 1)

            Text(text)
                .frame(alignment: .top)
        }
    }
}

#Preview {
    VStack {
        StepView(text: "example text", style: .circle(1))
        StepView(text: "example text", style: .custom("checkmark.circle.fill", .black))
    }
}
