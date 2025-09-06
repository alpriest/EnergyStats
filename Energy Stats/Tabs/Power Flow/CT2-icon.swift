//
//  CT2-icon.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/10/2023.
//

import SwiftUI

struct CT2_icon: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color("background_inverted"))
            .frame(width: 42, height: 42)
            .overlay(
                VStack {
                    Text("CT2")
                        .fontWeight(.heavy)
                        .foregroundStyle(Color.background)
                }
            )
    }
}

#Preview {
    CT2_icon()
}
