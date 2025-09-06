//
//  CalculationBreakdownRectangle.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2025.
//

import SwiftUI

struct CalculationBreakdownRectangle: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            ConcentricRectangle(corners: .concentric)
                .stroke(Color("highlight_box"), lineWidth: 1)
                .background(Color("highlight_box").opacity(0.1))
        } else {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color("highlight_box"), lineWidth: 1)
                .background(Color("highlight_box").opacity(0.1))
        }
    }
}

#Preview {
    CalculationBreakdownRectangle()
}
