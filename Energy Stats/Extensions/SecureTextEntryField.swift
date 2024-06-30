//
//  SecureTextField.swift
//  Energy Stats
//
//  Created by Alistair Priest on 30/06/2024.
//

import SwiftUI

struct SecureTextField: View {
    let title: String
    @Binding var text: String
    @State private var isSecure = true

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        Group {
            if isSecure {
                SecureField(text: $text) {
                    Text(title)
                }
            } else {
                TextField(text: $text) {
                    Text(title)
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .overlay(
            HStack {
                Spacer()

                Button(action: {
                    isSecure.toggle()
                }, label: {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .resizable()
                        .frame(height: isSecure ? 20 : 16)
                        .aspectRatio(contentMode: .fit)
                })
                .padding(.trailing)
            }
            .padding(.trailing, 6)
            .frame(minWidth: 0, maxWidth: .infinity)
        )
    }
}

#Preview {
    SecureTextFieldPreview()
}

struct SecureTextFieldPreview: View {
    @State private var text = ""

    var body: some View {
        VStack {
            SecureTextField("API Key", text: $text)

            Text(text)
        }
    }
}
