//
//  TipKitViewModifier.swift
//  Energy Stats
//
//  Created by Alistair Priest on 24/03/2025.
//

import Energy_Stats_Core
import SwiftUI

struct TipKitViewModifier: ViewModifier {
    let tip: TipType
    @State var showingAlert = false

    init(tip: TipType) {
        self.tip = tip
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !TipKitManager.shared.hasSeen(tip: tip) {
                    showingAlert = true
                }
            }
            .alert(tip.title, isPresented: $showingAlert) {
                Button("OK") {
                    TipKitManager.shared.markAsSeen(tip: tip)
                }
            } message: {
                Text(tip.body)
            }
    }
}

extension View {
    func tipKit(tip: TipType) -> some View {
        modifier(TipKitViewModifier(tip: tip))
    }
}
