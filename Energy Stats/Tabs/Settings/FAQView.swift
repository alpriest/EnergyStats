//
//  FAQView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/06/2023.
//

import SwiftUI
import MarkdownUI

struct FAQView: View {
    var body: some View {
        Group {
            if let text {
                ScrollView {
                    Markdown(text)
                        .padding()
                }
            } else {
                ProgressView()
                    .task {
                        if let (data, _) = try? await URLSession.shared.data(from: URL(string: "https://raw.githubusercontent.com/wiki/alpriest/EnergyStats/FAQ.md")!),
                           let string = String(data: data, encoding: .utf8)
                        {
                            self.text = string
                        }
                    }
            }
        }.navigationTitle("Frequently Asked Questions")
    }

    @State private var text: String?
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}
