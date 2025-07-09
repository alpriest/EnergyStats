//
//  CrossHatchView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/07/2025.
//

import SwiftUI

public struct CrossHatchView: View {
    public let spacing: CGFloat = 15
    public let lineWidth: CGFloat = 5
    public let color: Color = .red.opacity(0.15)

    public init() {}

    public var body: some View {
        Canvas { context, size in
            let path = Path { path in
                let width = size.width
                let height = size.height

                // Bottom-left to top-right
                stride(from: 0, through: width + height, by: spacing).forEach { offset in
                    path.move(to: CGPoint(x: offset, y: 0))
                    path.addLine(to: CGPoint(x: offset - height, y: height))
                }
            }

            context.stroke(path, with: .color(color), lineWidth: lineWidth)
        }
    }
}
