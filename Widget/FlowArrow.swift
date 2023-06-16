//
//  FlowArrow.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 16/06/2023.
//

import SwiftUI

struct FlowArrow: View {
    let amount: Double
    let color: Color

    var body: some View {
        Group {
            if amount > 0 {
                Image(systemName: "arrow.down.circle")
            } else if amount < 0 {
                Image(systemName: "arrow.up.circle")
            }
        }
        .fontWeight(.bold)
        .foregroundColor(color)
    }
}


struct FlowArrow_Previews: PreviewProvider {
    static var previews: some View {
        FlowArrow(amount: 1.0, color: .red)
    }
}
