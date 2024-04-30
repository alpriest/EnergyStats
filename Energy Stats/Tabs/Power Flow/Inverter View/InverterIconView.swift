//
//  InverterIconView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/08/2023.
//

import Energy_Stats_Core
import SwiftUI

struct InverterIconPath: View {
    var body: some View {
        Canvas { context, size in
            let cablesHeight = size.height * 0.12
            let cablesWidth = size.width * 0.1
            let cornerSize = CGSize(width: 3, height: 3)
            let inverterLineWidth: CGFloat = 3
            let cablesLineWidth: CGFloat = 2

            let inverter = Path { path in
                path.addRoundedRect(in: CGRect(x: inverterLineWidth / 2.0, y: inverterLineWidth / 2.0, width: size.width - inverterLineWidth, height: size.height - inverterLineWidth - cablesHeight), cornerSize: cornerSize)
            }

            let cable1 = Path { path in
                path.addRect(CGRect(x: cablesWidth * 1.5, y: size.height - cablesHeight - cablesLineWidth, width: cablesWidth, height: cablesHeight))
            }

            let cable2 = Path { path in
                path.addRect(CGRect(x: cablesWidth * 3.5, y: size.height - cablesHeight - cablesLineWidth, width: cablesWidth, height: cablesHeight))
            }

            context.fill(inverter, with: .color(Color("background_inverted")))
            context.stroke(inverter, with: .color(Color("background_inverted")), lineWidth: inverterLineWidth)
            context.stroke(cable1, with: .color(Color("background_inverted")), lineWidth: cablesLineWidth)
            context.stroke(cable2, with: .color(Color("background_inverted")), lineWidth: cablesLineWidth)
        }
    }
}

struct InverterIconView: View {
    @State private var size: CGSize = .zero
    @State private var opacity = 1.0
    let deviceFaulty: Bool

    var deviceStateColor: Color {
        switch deviceFaulty {
        case false:
            Color.gray
        case true:
            Color("lines_negative")
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            InverterIconPath()

            Group {
                switch deviceFaulty {
                case false:
                    deviceStateColor
                case true:
                    deviceStateColor
                        .onAppear {
                            switch deviceFaulty {
                            case false:
                                opacity = 1.0
                            case true:
                                withAnimation(.snappy(duration: 0.4).repeatForever(autoreverses: true)) { opacity = 0.2 }
                            }
                        }
                }
            }
            .frame(width: (size.width / 13) * 4.8, height: (size.height / 20) * 6)
            .offset(x: (size.width / 13) * 2, y: (size.height / 20) * 4)
            .opacity(opacity)

            Image(systemName: "bolt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: size.height / 2.5)
                .offset(x: (size.width / 5) * 3, y: size.height * 0.2)
                .foregroundColor(Color.background)
        }
        .background(
            GeometryReader { reader in
                Color.clear.onAppear { size = reader.size }
                    .onChange(of: reader.size) { newValue in
                        size = newValue
                    }
            }
        )
        .padding(2)
        .background(Color.background)
    }
}

#Preview {
    InverterIconView(deviceFaulty: false)
        .frame(width: 150, height: 180)
}
