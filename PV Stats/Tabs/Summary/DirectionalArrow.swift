//
//  DirectionalArrow.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.size.height))
        }
    }
}

struct DirectionalArrow: View {
    @State var phase: CGFloat = 0
    private let totalPhase: CGFloat = 20
    private let lineWidth: CGFloat = 4
    let direction: Direction
    let animationDuration: Double

    enum Direction {
        case down
        case up
    }

    var body: some View {
        Line()
            .stroke(
                style: strokeStyle
            )
            .animation(
                Animation.linear(duration: animationDuration)
                    .repeatForever(autoreverses: false),
                value: phase)
            .foregroundColor(Color("lines"))
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
            dashPhase: phase)
    }
}

struct DirectionalArrow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DirectionalArrow(direction: .up, animationDuration: 1.0)
                .frame(width: 200, height: 200)
                .background(Color.red)
        }
    }
}
