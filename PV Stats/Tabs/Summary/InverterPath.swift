//
//  InverterPath.swift
//  PV Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import SwiftUI

struct InverterPath: Shape {
    private let joinSize: Double = 3

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.height / 2.0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2.0))
            path.move(to: CGPoint(x: rect.width, y: rect.height / 2.0))

            path.addRect(CGRect(x: 0, y: rect.midY - halfJoinSize, width: joinSize, height: joinSize))
            path.addRect(CGRect(x: rect.width - joinSize, y: rect.midY - halfJoinSize, width: joinSize, height: joinSize))
            path.addRect(CGRect(x: rect.midX - halfJoinSize, y: rect.midY - halfJoinSize, width: joinSize, height: joinSize))
        }
    }

    private var halfJoinSize: Double { joinSize / 2.0 }
}

struct InverterView: View {
    var body: some View {
        InverterPath()
            .stroke(lineWidth: 2)
            .foregroundColor(Color("lines"))
    }
}

struct InverterView_Previews: PreviewProvider {
    static var previews: some View {
        InverterView()
            .background(Color.gray.opacity(0.3))
    }
}
