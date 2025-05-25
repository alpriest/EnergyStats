//
//  ESLabeledText.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/04/2025.
//

import Energy_Stats_Core
import SwiftUI

struct ESLabeledText: View {
    let title: LocalizedStringKey
    let value: String?
    let copiable: Bool

    init(_ title: LocalizedStringKey, value: String?, copiable: Bool = false) {
        self.title = title
        self.value = value
        self.copiable = copiable
    }

    var body: some View {
        Group {
            if let value {
                LabeledContent(title, value: value)
                    .if(copiable) {
                        $0.alertCopy("\(title): \(value)")
                    }
            }
        }
    }
}
