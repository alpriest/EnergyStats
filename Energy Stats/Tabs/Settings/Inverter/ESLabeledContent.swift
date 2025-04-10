//
//  ESLabeledContent.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/04/2025.
//

import Energy_Stats_Core
import SwiftUI

struct ESLabeledContent<Content: View>: View {
    let title: String
    let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        Group {
            LabeledContent(title, content: content)
        }
    }
}
