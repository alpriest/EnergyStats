//
//  WelcomeView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 14/09/2024.
//

import Energy_Stats_Core
import SwiftUI

struct WelcomeView: View {
    @ObservedObject var userManager: UserManager
    @State private var size: CGSize = .zero
    @State private var showingAPIKey = false
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        if verticalSizeClass == .regular {
            portraitView()
                .ignoresSafeArea()
        } else {
            landscapeView()
        }
    }

    func landscapeView() -> some View {
        HStack(spacing: 0) {
            VStack {
                ZStack {
                    HStack {
                        Text(verbatim: "E")
                        Spacer()
                    }
                    .foregroundStyle(Color("background_inverted").opacity(0.3))
                    .font(.system(size: 230, weight: .bold))

                    HStack {
                        Spacer()
                        Text(verbatim: "S")
                    }
                    .foregroundStyle(Color("background_inverted").opacity(0.3))
                    .font(.system(size: 218, weight: .bold))
                }
                .frame(maxWidth: 210, maxHeight: 240)
            }
            .frame(width: 300)
            .frame(maxHeight: .infinity)
            .background(Color.yellow.opacity(0.1))

            Spacer()

            if showingAPIKey {
                ScrollView {
                    APIKeyLoginView(userManager: userManager)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
                }
            } else {
                welcomeMessage()
            }
        }
    }

    func logo() -> some View {
        VStack {
            ZStack {
                HStack {
                    Text(verbatim: "E")
                    Spacer()
                }
                .foregroundStyle(Color("background_inverted").opacity(0.3))
                .font(.system(size: showingAPIKey ? 230 : 430, weight: .bold))

                HStack {
                    Spacer()
                    Text(verbatim: "S")
                }
                .foregroundStyle(Color("background_inverted").opacity(0.3))
                .font(.system(size: showingAPIKey ? 218 : 418, weight: .bold))
            }
            .frame(maxWidth: showingAPIKey ? 200 : 430, maxHeight: showingAPIKey ? 200 : 340)
        }
        .frame(maxWidth: .infinity, maxHeight: showingAPIKey ? 280 : 380)
        .background(Color.yellow.opacity(0.1))
    }

    func portraitView() -> some View {
        Group {
            if showingAPIKey {
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(maxHeight: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.1))

                        logo()

                        APIKeyLoginView(userManager: userManager)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(maxHeight: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow.opacity(0.1))

                    logo()

                    Spacer()

                    welcomeMessage()
                        .padding([.bottom, .horizontal])

                    Spacer()
                }
            }
        }
    }

    func welcomeMessage() -> some View {
        VStack(alignment: .leading, spacing: 44) {
            Text("Energy management at your fingertips")
                .font(.system(size: 48, weight: .bold))

            Button {
                withAnimation(.easeIn) {
                    showingAPIKey = true
                }
            } label: {
                Text("Get started")
                    .frame(minWidth: 0, maxWidth: 300)
                    .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    WelcomeView(userManager: .preview())
}
