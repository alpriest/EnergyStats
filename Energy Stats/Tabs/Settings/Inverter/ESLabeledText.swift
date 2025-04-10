//
//  ESLabeledText.swift
//  
//
//  Created by Alistair Priest on 08/04/2025.
//


import Energy_Stats_Core
import SwiftUI

struct ESLabeledText: View {
    let title: String
    let value: String?

    init(_ title: String, value: String?) {
        self.title = title
        self.value = value
    }

    var body: some View {
        Group {
            if let value {
                LabeledContent(title, value: value)
            }
        }
    }
}