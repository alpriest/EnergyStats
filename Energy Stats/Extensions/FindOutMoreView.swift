//
//  FindOutMoreView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/07/2025.
//

import SwiftUI

struct FindOutMoreView: View {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    init(urlString: String) {
        self.url = URL(string: urlString)!
    }

    var body: some View {
        Link(destination: url) {
            HStack {
                Text("Find out more")
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .font(.caption)
        }
    }
}

#Preview {
    FindOutMoreView(urlString: "https://www.google.com")
}
