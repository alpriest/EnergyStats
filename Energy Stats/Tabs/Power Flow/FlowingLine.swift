//
//  DirectionalArrow.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct MidYHorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.size.height))
        }
    }
}

struct FlowingLine<S: Shape>: View {
    @State var phase: CGFloat = 0
    private let totalPhase: CGFloat = 20
    private let lineWidth: CGFloat = 4
    let direction: Direction
    let animationDuration: Double
    let color: Color
    let shape: S

    enum Direction {
        case down
        case up
    }

    var body: some View {
        shape
            .stroke(
                style: strokeStyle
            )
            .animation(.linear(duration: animationDuration).repeatForever(autoreverses: false), value: phase)
            .foregroundColor(color)
            .onAppear {
                switch direction {
                case .down:
                    phase = 0 - totalPhase
                case .up:
                    phase = totalPhase
                }
            }
    }

    var strokeStyle: StrokeStyle {
        StrokeStyle(
            lineWidth: lineWidth,
            dash: [totalPhase / 2.0],
            dashPhase: phase
        )
    }
}

#Preview {
    HStack {
        FlowingLine(direction: .up, animationDuration: 1.5, color: .red, shape: MidYHorizontalLine())
            .frame(width: 100, height: 300)
            .background(Color.gray)
    }
}
