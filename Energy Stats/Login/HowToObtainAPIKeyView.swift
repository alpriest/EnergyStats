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

            StepView(text: "how_to_get_api_key_1", style: .circle(1))
            StepView(text: "how_to_get_api_key_2", style: .circle(2))
            StepView(text: "how_to_get_api_key_3", style: .circle(2))
            StepView(text: "how_to_get_api_key_4", style: .circle(4))
            StepView(text: "how_to_get_api_key_5", style: .circle(5))
            StepView(text: "how_to_get_api_key_6", style: .circle(6))
            StepView(text: "how_to_get_api_key_7", style: .circle(7))

            Text("What is my API key?")
                .font(.headline)
                .buttonStyle(.bordered)
                .padding(.top)

            VStack(alignment: .leading, spacing: 8) {
                Text("what_is_api_key_1")
                Text("what_is_api_key_2")
                Text("what_is_api_key_3")
                Text("what_is_api_key_4")
                Text("what_is_api_key_5")
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
        }
    }
}
