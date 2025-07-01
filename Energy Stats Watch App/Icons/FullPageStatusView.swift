//
//  FullPageStatusView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/07/2025.
//

import SwiftUI

struct FullPageStatusView<V: View, T1: View, T2: View>: View {
    let iconScale: IconScale
    let icon: () -> V
    let line1: () -> T1
    let line2: () -> T2

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .bottom) {
                Color.clear
                icon()
            }
            .frame(height: iconScale.size.height)

            line1()
                .font(iconScale.line1Font)
            line2()
                .font(iconScale.line2Font)
        }
    }
}
