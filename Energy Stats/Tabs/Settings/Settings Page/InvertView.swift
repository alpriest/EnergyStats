//
//  InvertView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 28/03/2025.
//

import SwiftUI

struct InvertView: View {
    var body: some View {
        Form {
            Section {
                VStack {
                    Text("invert_summary")
                        .padding(.bottom, 48)

                    Button {
                        UIApplication.shared.open(URL(string: "https://invert.energy/fox-ess/")!)
                    } label: {
                        VStack {
                            Text("Visit Invert")
                                .font(.headline)

                            Text("https:\\/\\/invert.energy\\/fox-ess")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                }
            }
        }.navigationTitle("Invert")
    }
}

#Preview {
    NavigationView {
        InvertView()
    }
}
