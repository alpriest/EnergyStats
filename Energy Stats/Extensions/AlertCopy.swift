//
//  AlertCopy.swift
//  Energy Stats
//
//  Created by Alistair Priest on 04/08/2023.
//

import SwiftUI

struct AlertCopy: ViewModifier {
    let text: String
    @State private var showAlert = false

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                showAlert.toggle()
            }
            .alert("Copied!", isPresented: $showAlert, actions: {})
    }
}

extension View {
    func alertCopy(_ text: String) -> some View {
        modifier(AlertCopy(text: text))
    }
}

#Preview {
    Text("Hello")
        .alertCopy("Hello")
}
