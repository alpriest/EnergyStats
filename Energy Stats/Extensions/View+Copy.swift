//
//  View+Copy.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/04/2023.
//

import SwiftUI

extension View {
    func copy(text: String) -> some View {
        contextMenu {
            Button(action: {
                UIPasteboard.general.string = text
            }) {
                Text("Copy to clipboard")
                Image(systemName: "doc.on.doc")
            }
        }
    }
}

struct CopyButton: View {
    let text: String

    var body: some View {
        Button(action: {
            UIPasteboard.general.string = text
        }) {
            Image(systemName: "doc.on.doc")
        }
    }
}
