//
//  PylonView.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 03/04/2023.
//

import SwiftUI

public struct PylonView: View {
    private let lineWidth: CGFloat

    public init(lineWidth: CGFloat = 2) {
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            PylonShape(lineWidth: lineWidth)
                .stroke(lineWidth: lineWidth)
                .padding(2)
                .clipped()

            Color.white.frame(width: .infinity, height: lineWidth / 2.0)
        }
    }
}

struct PylonShape: Shape {
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let hSize = rect.width * 0.1
        let vSize = rect.height * 0.1

        let leftLegBottom = CGPoint(x: hSize * 2.5, y: rect.maxY + (lineWidth / 2.0))
        let leftLegTop = CGPoint(x: hSize * 4, y: 0 + (lineWidth / 2.0))
        let rightLegBottom = CGPoint(x: hSize * 7.5, y: rect.maxY + (lineWidth / 2.0))
        let rightLegTop = CGPoint(x: hSize * 6, y: 0 + (lineWidth / 2.0))

        return Path { path in
            path.move(to: leftLegBottom)
            path.addLine(to: leftLegTop)
            path.addLine(to: rightLegTop)
            path.addLine(to: rightLegBottom)

            // highest bar
            path.move(to: CGPoint(x: hSize * 1, y: vSize * 2.5))
            path.addLine(to: CGPoint(x: hSize * 9, y: vSize * 2.5))

            // middle bar bar
            path.move(to: CGPoint(x: 0, y: vSize * 5))
            path.addLine(to: CGPoint(x: rect.maxX, y: vSize * 5))

            // cross
            path.move(to: leftLegBottom)
            path.addLine(to: CGPoint(x: hSize * 6.8, y: vSize * 5))

            // cross
            path.move(to: rightLegBottom)
            path.addLine(to: CGPoint(x: hSize * 3.2, y: vSize * 5))
        }
    }
}

struct PylonView_Previews: PreviewProvider {
    static var previews: some View {
        PylonView(lineWidth: 2)
            .frame(width: 45, height: 45)
    }
}
