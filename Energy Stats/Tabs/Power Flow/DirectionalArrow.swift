//
//  DirectionalArrow.swift
//  Energy Stats
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
            .animation(.linear(duration: animationDuration).repeatForever(autoreverses: false), value: phase)
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

//struct DirectionalArrow: View {
//    @State var yOffset: Double = 0
//    @State private var timer: Timer?
//    private let totalPhase: CGFloat = 20
//    let direction: Direction
//    let animationDuration: Double
//
//        enum Direction {
//            case down
//            case up
//        }
//
//    var body: some View {
//        GeometryReader { reader in
//            Color.clear
//                .background(
//                    Line()
//                        .stroke(style: StrokeStyle(lineWidth: 4.0, dash: [totalPhase / 2.0], dashPhase: 0))
//                        .frame(height: reader.size.height * 3.0)
//                        .foregroundColor(Color("lines"))
//                        .offset(y: yOffset)
//                        .onAppear {
//                            timer?.invalidate()
//                            setupTimer()
//                        }
//                        .onChange(of: animationDuration) { newValue in
//                            timer?.invalidate()
//                            setupTimer()
//                        }
//                        .onChange(of: yOffset) { newValue in
//                            switch direction {
//                            case .down:
//                                if yOffset >= reader.size.height {
//                                    yOffset = 0
//                                }
//                            case .up:
//                                if yOffset <= 0 {
//                                    yOffset = reader.size.height
//                                }
//                            }
//                        }
//                ).clipped()
//        }
//    }
//
//    func setupTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: animationDuration / 20, repeats: true) { _ in
//            switch direction {
//            case .down:
//                yOffset += 1
//            case .up:
//                yOffset -= 1
//            }
//        }
//    }
//}

struct DirectionalArrow_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
//            DirectionalArrow(direction: .up, animationDuration: 1.5)
//                .frame(width: 100, height: 300)
//                .background(Color.red)

            DirectionalArrow(direction: .up, animationDuration: 1.5)
                .frame(width: 100, height: 300)
                .background(Color.red)
        }
    }
}
