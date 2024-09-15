//
//  HowToObtainAPIKeyView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/02/2024.
//

import SwiftUI

struct HowToObtainAPIKeyView: View {
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
            step(8, text: "Your API key will be 36 characters long and look something like abcde123-4567-8901-2345-6789abcdef01")

            Text("api_key_change_reason_2")
                .font(.caption2)
                .padding(.top)

            Text("api_key_change_reason")
                .font(.caption2)
                .padding(.top)
        }
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
    HowToObtainAPIKeyView()
}
