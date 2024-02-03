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

struct ErrorAlertView: View {
    let cause: Error?
    let message: String
    let allowRetry: Bool
    let retry: () -> Void
    @EnvironmentObject var userManager: UserManager
    @State private var buttonWidth: CGFloat = .zero
    @State private var showingFatalError = false
    @State private var showingUpgradeRequired = false

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

            Button {
                UIPasteboard.general.string = debugData
            } label: {
                Text("Copy debug data")
            }
            .buttonStyle(EqualWidthButtonStyle(buttonWidth: $buttonWidth))

            VStack {
                if allowRetry {
                    Button(action: { retry() }) {
                        Text("Retry")
                            .background(rectReader($buttonWidth))
                            .frame(minWidth: buttonWidth)
                    }
                    .buttonStyle(EqualWidthButtonStyle(buttonWidth: $buttonWidth))
                }

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

            Button(action: { userManager.logout() }) {
                Text("logout")
                    .background(rectReader($buttonWidth))
                    .frame(minWidth: buttonWidth)
            }
            .buttonStyle(EqualWidthButtonStyle(buttonWidth: $buttonWidth))
        }.onAppear {
            guard let cause = cause as? NetworkError else { return }
            if case .requestRequiresSignature = cause {
                showingFatalError = true
            }

            if case .badCredentials = cause {
                showingUpgradeRequired = true
            }

            if case .invalidToken = cause {
                showingUpgradeRequired = true
            }
        }
        .sheet(isPresented: $showingFatalError, content: { UnsupportedErrorView() })
        .sheet(isPresented: $showingUpgradeRequired, content: { UpgradeRequiredView(userManager: userManager)
                .interactiveDismissDisabled()
        })
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
            message
        } else if let cause {
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

    var popupMessage: String {
        cause?.localizedDescription ?? message
    }
}

#if DEBUG
#Preview {
    ErrorAlertView(
        cause: NetworkError.badCredentials,
        message: "This is a long message. This is a long message. This is a long message. This is a long message",
        allowRetry: true,
        retry: {}
    )
    .environmentObject(UserManager.preview())
    .environment(\.locale, .init(identifier: "de"))
}
#endif
