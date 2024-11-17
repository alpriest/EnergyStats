//
//  FAQView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/06/2023.
//

import MarkdownUI
import SwiftUI

struct RemoteMarkdownView: View {
    let url: String
    @State private var text: String?

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
                        if let (data, _) = try? await URLSession.shared.data(from: URL(string: url)!),
                           let string = String(data: data, encoding: .utf8)
                        {
                            self.text = string
                        }
                    }
            }
        }
    }
}

struct FAQView: View {
    var body: some View {
        RemoteMarkdownView(url: "https://raw.githubusercontent.com/wiki/alpriest/EnergyStats/FAQ.md")
            .navigationTitle(.faq)
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}
