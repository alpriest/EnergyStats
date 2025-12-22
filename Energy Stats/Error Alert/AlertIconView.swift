//
//  AlertIconView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/12/2025.
//

import Energy_Stats_Core
import SwiftUI

struct AlertIconView: View {
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: reader.size.width, height: reader.size.height)

                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: reader.size.width * 0.76, height: reader.size.height * 0.76)
            }
        }
    }
}
