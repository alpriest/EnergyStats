//
//  PylonView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct PylonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let hSize = rect.width * 0.1
        let vSize = rect.height * 0.1

        let leftLegBottom = CGPoint(x: hSize * 2.5, y: rect.maxY)
        let leftLegTop = CGPoint(x: hSize * 4, y: 0)
        let rightLegBottom = CGPoint(x: hSize * 7.5, y: rect.maxY)
        let rightLegTop = CGPoint(x: hSize * 6, y: 0)

        return Path { path in
            path.move(to: leftLegBottom)
            path.addLine(to: leftLegTop)
            path.addLine(to: rightLegTop)
            path.addLine(to: rightLegBottom)

            path.move(to: CGPoint(x: hSize * 1, y: vSize * 2.5))
            path.addLine(to: CGPoint(x: hSize * 9, y: vSize * 2.5))

            path.move(to: CGPoint(x: 0, y: vSize * 5))
            path.addLine(to: CGPoint(x: rect.maxX, y: vSize * 5))

            path.move(to: leftLegBottom)
            path.addLine(to: CGPoint(x: hSize * 6.9, y: vSize * 5))

            path.move(to: rightLegBottom)
            path.addLine(to: CGPoint(x: hSize * 3.1, y: vSize * 5))
        }
    }
}

struct PylonView: View {
    var body: some View {
        PylonShape()
            .stroke(lineWidth: 3)
            .padding(2)
    }
}

struct PylonView_Previews: PreviewProvider {
    static var previews: some View {
        PylonView()
            .frame(width: 30, height: 27)
    }
}
