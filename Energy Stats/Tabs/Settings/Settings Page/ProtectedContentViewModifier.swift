//
//  ProtectedContentViewModifier.swift
//  Energy Stats
//
//  Created by Alistair Priest on 22/02/2026.
//

import Energy_Stats_Core
import SwiftUI

struct ProtectedContentViewModifier: ViewModifier {
    let configManager: ConfigManaging

    func body(content: Content) -> some View {
        if configManager.isReadOnly {
            VStack(spacing: 24) {
                Image(systemName: "nosign")
                    .font(.system(size: 96, weight: .heavy))
                    .foregroundStyle(Color.linesNegative)
                Text("This functionality is not available in read-only mode")
            }.padding()
        } else {
            content
        }
    }
}

extension View {
    func protectedContent(_ configManager: ConfigManaging) -> some View {
        modifier(ProtectedContentViewModifier(configManager: configManager))
    }
}

#Preview {
    Text("dgd")
        .protectedContent(ConfigManager.preview(config: MockConfig.make { $0.isReadOnly = true }))
}
