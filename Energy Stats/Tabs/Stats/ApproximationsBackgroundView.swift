//
//  ApproximationsBackgroundView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2025.
//

import Energy_Stats_Core
import SwiftUI

struct ApproximationsBackgroundView: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            ConcentricRectangle()
                .stroke(Color("highlight_box"), lineWidth: 1)
                .background(Color("highlight_box").opacity(0.1))
                .padding(1)
        } else {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color("highlight_box"), lineWidth: 1)
                .background(Color("highlight_box").opacity(0.1))
                .padding(1)
        }
    }
}
