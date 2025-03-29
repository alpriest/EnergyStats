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
                    Text("Energy Stats is not affiliated with Invert, but we believe their service may help users of Fox ESS inverters optimise energy usage and save money.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 48)

                    Button {
                        UIApplication.shared.open(URL(string: "https://invert.energy/fox-ess/")!)
                    } label: {
                        VStack {
                            Text("Visit Invert")
                                .font(.headline)

                            Text("https:\\/\\/invert.energy\\/fox-ess")
                        }.frame(maxWidth: .infinity)
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
