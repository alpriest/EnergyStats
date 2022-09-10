//
//  CircularProgressView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: CGFloat
    let subtitle: String?

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.gray)
                .opacity(0.2)

            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(AngularGradient(colors: [.yellow, .orange, .pink, .red], center: .center), style: StrokeStyle(lineWidth: 20, lineCap: .butt, lineJoin: .miter))
                .rotationEffect(.degrees(-90))
                .shadow(radius: 2)

            if let subtitle = subtitle {
                VStack {
                    Text("\(String(format: "%0.0f", progress * 100))%")
                        .font(.largeTitle)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

        }
        .frame(width: 200, height: 200)
        .padding()
        .animation(.easeInOut, value: progress)
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.25, subtitle: "+0.11kW")
    }
}
