//
//  ErrorAlertView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/11/2022.
//

import Energy_Stats_Core
import SwiftUI

enum ErrorAlertType {
    case fox
    case solcast
}

final class FoxErrorAlertViewManufacturing: ErrorAlertViewManufacturing {
    func make(cause: Error?, message: String, options: ErrorAlertViewOptions, retry: @escaping () -> Void) -> any View {
        ErrorAlertView(cause: cause, message: message, options: options, retry: retry)
    }
}

struct ErrorAlertView: View {
    let cause: Error?
    let message: String
    let options: ErrorAlertViewOptions
    let retry: () -> Void
    @EnvironmentObject var userManager: UserManager
    @State private var buttonWidth: CGFloat = .zero
    @State private var showingFatalError = false
    @State private var alertContent: AlertContent?

    init(cause: Error?, message: String, options: ErrorAlertViewOptions, retry: @escaping () -> Void) {
        self.cause = cause
        self.message = message
        self.options = options
        self.retry = retry
    }

    var body: some View {
        VStack {
            AlertIconView()
                .frame(height: 130)

            Text(inlineMessage)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            Text(detailedMessage)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .font(.caption)

            if options.contains(.retry) {
                Button(action: { retry() }) {
                    Text("Retry")
                        .background(rectReader($buttonWidth))
                        .frame(minWidth: buttonWidth)
                }
                .buttonStyle(EqualWidthButtonStyle(buttonWidth: $buttonWidth))
            }

            if options.contains(.checkServerStatus) {
                Button {
                    let url = URL(string: "https://monitor.foxesscommunity.com/")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } label: {
                    Text("Check FoxESS Server status")
                        .background(rectReader($buttonWidth))
                        .frame(minWidth: buttonWidth)
                }
                .buttonStyle(EqualWidthButtonStyle(buttonWidth: $buttonWidth))
            }

            if options.contains(.logoutButton) {
                Button(action: { Task { await userManager.logout() } }) {
                    Text("Logout")
                        .background(rectReader($buttonWidth))
                        .frame(minWidth: buttonWidth)
                }
                .buttonStyle(EqualWidthButtonStyle(buttonWidth: $buttonWidth))
            }
        }.onAppear {
            guard let cause = cause as? NetworkError else { return }
            if case .requestRequiresSignature = cause {
                showingFatalError = true
            }
        }.sheet(isPresented: $showingFatalError) {
            UnsupportedErrorView()
        }.alert(alertContent: $alertContent)
    }

    private func rectReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { gr -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = max(binding.wrappedValue, gr.frame(in: .local).width)
            }
            return Color.clear
        }
    }

    var detailedMessage: String {
        return if let cause = cause as? NetworkError {
            switch cause {
            case .invalidToken:
                String(localized: "Your API token is invalid. Please logout and follow the instructions to generate a new API token.")
            case .timedOut:
                String(localized: "foxess_timeout")
            default:
                message
            }
        } else if let cause, cause is DecodingError {
            String(describing: cause)
        } else if let cause, cause.localizedDescription != message {
            "\(message)\n\n\(cause.localizedDescription)"
        } else {
            message
        }
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
}

#if DEBUG
#Preview {
    ErrorAlertView(
        cause: NetworkError.missingData,
        message: "This is a long message. This is a long message. This is a long message. This is a long message",
        options: .all,
        retry: {}
    )
    .environmentObject(UserManager.preview())
}
#endif
