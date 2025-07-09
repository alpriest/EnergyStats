//
//  FindOutMoreView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/07/2025.
//

import SwiftUI

public struct FindOutMoreView: View {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public init(urlString: String) {
        self.url = URL(string: urlString)!
    }

    public var body: some View {
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
