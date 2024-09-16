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
    @State private var logoSize: CGRect = .zero
    private let yellowBackground = Color.yellow.opacity(0.2)

    var body: some View {
        if verticalSizeClass == .regular {
            portraitView()
        } else {
            landscapeView()
        }
    }

    func landscapeView() -> some View {
        HStack(spacing: 0) {
            portraitLogo()
                .padding(.trailing)
                .frame(width: 300)
                .frame(maxHeight: .infinity)
                .background(yellowBackground)

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

    func portraitLogo() -> some View {
        Image("es-icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    func portraitView() -> some View {
        VStack(spacing: 0) {
            portraitLogo()
                .frame(minWidth: 0, maxWidth: showingAPIKey ? 150 : .infinity)
                .padding(.bottom, showingAPIKey ? 12 : 0)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(yellowBackground.ignoresSafeArea())

            if showingAPIKey {
                ScrollView {
                    APIKeyLoginView(userManager: userManager)
                }
            } else {
                Spacer()

                welcomeMessage()
                    .padding([.bottom, .horizontal])

                Spacer()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    func welcomeMessage() -> some View {
        VStack(alignment: .center, spacing: 44) {
            Text("Energy management at your fingertips")
                .font(.system(size: 48, weight: .bold))
                .multilineTextAlignment(.center)

            Button {
                withAnimation(.easeIn(duration: 0.2)) {
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
