//
//  UnsupportedErrorView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/12/2023.
//

import SwiftUI

struct UnsupportedErrorView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            RemoteMarkdownView(url: "https://raw.githubusercontent.com/wiki/alpriest/EnergyStats-Android/Unsupported.md")
                .navigationTitle("Unsupported")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                }
        }
    }
}

#Preview {
    UnsupportedErrorView()
}
