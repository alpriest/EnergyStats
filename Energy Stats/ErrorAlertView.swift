//
//  ErrorAlertView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/11/2022.
//

import Energy_Stats_Core
import SwiftUI

struct ErrorAlertView: View {
    @State private var ripple = false
    let cause: Error?
    let message: String
    let retry: () -> Void
    @State private var errorShowing = false
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack {
            Button(action: { errorShowing.toggle() }) {
                ZStack {
                    Circle()
                        .foregroundColor(.red)
                        .frame(width: ripple ? 130 : 99, height: ripple ? 130 : 99)

                    Image(systemName: "exclamationmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                }
                .transition(.opacity.combined(with: .scale.animation(.easeOut)))
                .animation(Animation.easeIn(duration: 0.06), value: ripple)
                .frame(height: 130)
                .onTapGesture {
                    errorShowing.toggle()
                }
            }

            Text(inlineMessage)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            Text(tapIconMessage)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            VStack {
                Button(action: { retry() }) {
                    Text("Retry")
                }.buttonStyle(.bordered)

                Button("Check FoxESS Server status") {
                    let url = URL(string: "https://monitor.foxesscommunity.com/")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }.buttonStyle(.bordered)
            }

            if showLogout {
                Button(action: { userManager.logout() }) {
                    Text("Logout")
                }.buttonStyle(.bordered)
            }
        }
        .frame(height: 200)
        .alert(detailedMessage, isPresented: $errorShowing) {
            Button("OK") {}
        }
        .onAppear { ripple = true }
    }

    var detailedMessage: String {
        "\(message)\n\n\(cause?.localizedDescription ?? "")"
    }

    var inlineMessage: String {
        if let cause, cause is NetworkError {
            return cause.localizedDescription
        }

        return String(key: .dataFetchError)
    }

    var tapIconMessage: String {
        String(key: .tapIconForDetail)
    }

    var popupMessage: String {
        cause?.localizedDescription ?? message
    }

    var showLogout: Bool {
        if let cause = cause as? NetworkError, case .badCredentials = cause {
            return true
        }

        return false
    }
}

#if DEBUG
struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorAlertView(
            cause: NetworkError.badCredentials,
            message: "This is a long message. This is a long message. This is a long message. This is a long message",
            retry: {}
        )
        .environmentObject(UserManager.preview())
        .environment(\.locale, .init(identifier: "de"))
    }
}
#endif
