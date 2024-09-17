//
//  HowToObtainAPIKeyView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/02/2024.
//

import SwiftUI

struct HowToObtainAPIKeyView: View {
    @State private var showing = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("To get your API key:")
                .padding(.bottom, 8)

            step(1, text: "Login at https://www.foxesscloud.com/")
            step(2, text: "Click the person icon top-right")
            step(3, text: "Click the User Profile menu option")
            step(4, text: "Click API management")
            step(5, text: "Click Generate API key")
            step(6, text: "Copy the API key (make a note of it securely)")
            step(7, text: "Paste the API key above")

            Button {
                withAnimation {
                    showing.toggle()
                }
            } label: {
                Text("What is my API key?")
            }
            .buttonStyle(.bordered)
            .padding(.top)
            .frame(minWidth: 0, maxWidth: .infinity)

            if showing {
                VStack(alignment: .leading, spacing: 8) {
                    Text("what_is_api_key_1")
                    Text("what_is_api_key_2")
                    Text("what_is_api_key_3")
                    Text("what_is_api_key_4")
                    Text("what_is_api_key_5")
                }
                .animation(.easeIn, value: showing)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.horizontal)
    }

    func step(_ count: Int, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top) {
            Circle()
                .fill(Color.yellow.opacity(0.7))
                .overlay(
                    Text(count, format: .number)
                        .font(.caption)
                )
                .frame(width: 18)
                .padding(.top, 1)

            Text(text)
                .frame(alignment: .top)
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            HowToObtainAPIKeyView()
            Spacer()
        }
    }
}
