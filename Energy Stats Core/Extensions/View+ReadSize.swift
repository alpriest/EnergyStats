//
//  readSize.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/10/2025.
//

import SwiftUI

extension View {
    func readSize(into value: Binding<CGSize>) -> some View {
        background(
            Color.clear.onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { size in
                DispatchQueue.main.async {
                    value.wrappedValue = size
                }
            }
        )
    }
}
