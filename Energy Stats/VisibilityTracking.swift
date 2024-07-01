//
//  VisibilityTracking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 01/07/2024.
//

import SwiftUI

protocol VisibilityTracking: AnyObject {
    var visible: Bool { get set }
}

extension View {
    func trackVisibility(on viewModel: VisibilityTracking) -> some View {
        self
            .onAppear {
                viewModel.visible = true
            }
            .onDisappear {
                viewModel.visible = false
            }
    }
}
