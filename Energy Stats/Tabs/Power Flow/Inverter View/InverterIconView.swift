//
//  InverterIconView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/08/2023.
//

import SwiftUI

struct InverterIconPath: View {
//    func path(in rect: CGRect) -> Path {
    var body: some View {

        return Canvas { context, size in
            let cablesHeight = size.height * 0.15
            let cablesWidth = size.width * 0.1
            let panelX = size.width * 0.15
            let panelY = size.height * 0.2
            let cornerSize = CGSize(width: 5, height: 5)
            let inverterLineWidth: CGFloat = 4
            let cablesLineWidth: CGFloat = 2

            let inverter = Path { path in
                path.addRoundedRect(in: CGRect(x: inverterLineWidth / 2.0, y: inverterLineWidth / 2.0, width: size.width - inverterLineWidth, height: size.height - inverterLineWidth - cablesHeight), cornerSize: cornerSize)
            }

            let cable1 = Path { path in
                path.addRoundedRect(in: CGRect(x: cablesWidth * 1.5, y: size.height - cablesHeight - cablesLineWidth, width: cablesWidth, height: cablesHeight), cornerSize: cornerSize)
            }

            let cable2 = Path { path in
                path.addRoundedRect(in: CGRect(x: cablesWidth * 3.5, y: size.height - cablesHeight - cablesLineWidth, width: cablesWidth, height: cablesHeight), cornerSize: cornerSize)
            }

            let screen = Path { path in
                path.addRect(CGRect(x: panelX, y: panelY, width: panelX * 2.5, height: panelY * 1.5))
            }

            context.fill(inverter, with: .color(.white))
            context.stroke(inverter, with: .color(.black), lineWidth: inverterLineWidth)
            context.stroke(cable1, with: .color(.black), lineWidth: cablesLineWidth)
            context.stroke(cable2, with: .color(.black), lineWidth: cablesLineWidth)
            context.fill(screen, with: .color(.gray.opacity(0.5)))
        }
    }
}

struct InverterIconView: View {
    @State private var size: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            InverterIconPath()

            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size.height / 2.5)
                .offset(x: -size.width / 7, y: size.height * 0.2)
        }.background(
            GeometryReader { reader in
                Color.clear.onAppear { size = reader.size }
                    .onChange(of: reader.size) { newValue in
                        size = newValue
                    }
            }
        )
    }
}

struct InverterIconView_Previews: PreviewProvider {
    static var previews: some View {
        InverterIconView()
            .frame(width: 50, height: 35)
    }
}
