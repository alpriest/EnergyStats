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
        speed: CGFloat = 40,
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

#Preview {
    HStack {
        MovingDashesView(color: .red, direction: .down)
            .frame(width: 10, height: 300)
            .background(Color.gray)
    }
}
