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

            StepView(text: "Login at https://www.foxesscloud.com/", style: .circle(1))
            StepView(text: "Click the person icon top-right", style: .circle(2))
            StepView(text: "Click the User Profile menu option", style: .circle(3))
            StepView(text: "Click API management", style: .circle(4))
            StepView(text: "Click Generate API key", style: .circle(5))
            StepView(text: "Copy the API key (make a note of it securely)", style: .circle(6))
            StepView(text: "Paste the API key above", style: .circle(7))

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
}

#Preview {
    ScrollView {
        VStack {
            HowToObtainAPIKeyView()
            Spacer()
        }
    }
}
