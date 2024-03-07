//
//  ErrorAlertView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/11/2022.
//

import Energy_Stats_Core
import SwiftUI

struct EqualWidthButtonStyle: ButtonStyle {
    @Binding var buttonWidth: CGFloat
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(rectReader($buttonWidth))
            .frame(minWidth: buttonWidth)
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(colorScheme == .dark ? Color.white.opacity(0.14) : Color.paleGray)
            .foregroundStyle(Color.accentColor)
            .cornerRadius(6)
    }

    private func rectReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { gr -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = max(binding.wrappedValue, gr.frame(in: .local).width)
            }
            return Color.clear
        }
    }
}

struct ErrorAlertViewOptions: OptionSet {
    let rawValue: Int

    static let checkServerStatus = ErrorAlertViewOptions(rawValue: 1 << 0)
    static let logoutButton = ErrorAlertViewOptions(rawValue: 1 << 1)
    static let retry = ErrorAlertViewOptions(rawValue: 1 << 2)
    static let copyDebugData = ErrorAlertViewOptions(rawValue: 1 << 3)
    static let all: ErrorAlertViewOptions = [.checkServerStatus, .logoutButton, .retry, .copyDebugData]
}

struct ErrorAlertView: View {
    let cause: Error?
    let message: String
    let options: ErrorAlertViewOptions
    let retry: () -> Void
    @EnvironmentObject var userManager: UserManager
    @State private var buttonWidth: CGFloat = .zero
    @State private var showingFatalError = false
    @State private var showingUpgradeRequired = false
    @State private var alertContent: AlertContent?

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: 130, height: 130)

                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
            }
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

            if options.contains(.copyDebugData) {
                Button {
                    UIPasteboard.general.string = debugData
                    alertContent = AlertContent(title: "Done", message: "Debug data has been copied to your clipboard.")
                } label: {
                    Text("Copy debug data")
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
                Button(action: { userManager.logout() }) {
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

            if case .badCredentials = cause {
                showingUpgradeRequired = true
            }
        }.sheet(isPresented: $showingFatalError) {
            UnsupportedErrorView()
        }.sheet(isPresented: $showingUpgradeRequired) {
            UpgradeRequiredView(userManager: userManager)
                .interactiveDismissDisabled()
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

    private var debugData: String {
        struct DebugDataText: Encodable {
            let request: String?
            let response: String?
            let data: String?
        }

        let dataString: String?
        if let data = InMemoryLoggingNetworkStore.shared.latestData {
            dataString = (String(data: data, encoding: .utf8) ?? "data could not be parsed")
        } else {
            dataString = nil
        }

        let result = DebugDataText(
            request: InMemoryLoggingNetworkStore.shared.latestRequest?.debugDescription,
            response: InMemoryLoggingNetworkStore.shared.latestResponse?.debugDescription,
            data: dataString
        )

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let jsonData = try encoder.encode(result)
            return String(data: jsonData, encoding: .utf8) ?? "Could not generate JSON"
        } catch {
            return "Could not generate JSON"
        }
    }

    var detailedMessage: String {
        return if let cause, cause is NetworkError {
            if case NetworkError.invalidToken = cause {
                "Your API token is invalid. Please logout and follow the instructions to generate a new API token."
            } else {
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
