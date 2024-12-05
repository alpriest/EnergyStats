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

struct AlertIconView: View {
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Circle()
                    .foregroundColor(.red)
                    .frame(width: reader.size.width, height: reader.size.height)

                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: reader.size.width * 0.76, height: reader.size.height * 0.76)
            }
        }
    }
}

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
    @State private var showingUpgradeRequired = false
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
        DebugDataText(store: InMemoryLoggingNetworkStore.shared).debugData
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

struct DebugDataText: Encodable {
    let request: String?
    let responseHeaders: [String]?
    let data: String?

    @MainActor
    init(store: InMemoryLoggingNetworkStore) {
        request = store.latestRequestResponseData?.value.request
        responseHeaders = store.latestRequestResponseData?.value.responseHeaders

        if let data = store.latestRequestResponseData?.value.responseData {
            self.data = (String(data: data, encoding: .utf8) ?? "data could not be parsed")
        } else {
            data = nil
        }
    }

    var debugData: String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let jsonData = try encoder.encode(self)
            return jsonData.formattedJSON()
        } catch {
            return "Could not generate JSON"
        }
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
