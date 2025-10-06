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

struct MovingDashesView: View {
    enum Direction { case up, down, left, right }

    var color: Color
    var direction: Direction
    var speed: CGFloat        // points per second
    var dashLength: CGFloat   // length of each dash along travel axis
    var dashSpacing: CGFloat  // gap between dashes along travel axis

    init(
        color: Color = .blue,
        direction: Direction = .right,
        speed: CGFloat = 120,
        dashLength: CGFloat = 10,
        dashSpacing: CGFloat = 5
    ) {
        self.color = color
        self.direction = direction
        self.speed = speed
        self.dashLength = dashLength
        self.dashSpacing = dashSpacing
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let cycle = max(1, dashLength + dashSpacing) // avoid /0
            let phase = CGFloat(t) * speed
            let offset = phase.truncatingRemainder(dividingBy: cycle)

            GeometryReader { proxy in
                let size = proxy.size

                Canvas { context, _ in
                    // Translate along the correct axis & direction
                    switch direction {
                    case .right: context.translateBy(x:  offset, y: 0)
                    case .left:  context.translateBy(x: -offset, y: 0)
                    case .down:  context.translateBy(x: 0, y:  offset)
                    case .up:    context.translateBy(x: 0, y: -offset)
                    }

                    var path = Path()

                    switch direction {
                    case .left, .right:
                        // Vertical dashes moving horizontally
                        var x = -dashLength
                        while x < size.width + dashLength {
                            path.addRect(CGRect(x: x, y: 0, width: dashLength, height: size.height))
                            x += cycle
                        }

                    case .up, .down:
                        // Horizontal dashes moving vertically
                        var y = -dashLength
                        while y < size.height + dashLength {
                            path.addRect(CGRect(x: 0, y: y, width: size.width, height: dashLength))
                            y += cycle
                        }
                    }

                    context.fill(path, with: .color(color))
                }
            }
        }
        .drawingGroup() // smoother on complex scenes
        .clipped()
    }
}
