//
//  ErrorAlertView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/11/2022.
//

import Energy_Stats_Core
import SwiftUI

struct ErrorAlertView: View {
    let cause: Error?
    let message: String
    let retry: () -> Void
    @State private var errorShowing = false
    @EnvironmentObject var userManager: UserManager

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

            Button(action: { errorShowing.toggle() }) {
                Text(tapIconMessage)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }.buttonStyle(.bordered)

            VStack {
                Button(action: { retry() }) {
                    Text("Retry")
                }.buttonStyle(.bordered)

                Button("Check FoxESS Server status") {
                    let url = URL(string: "https://monitor.foxesscommunity.com/")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }.buttonStyle(.bordered)
            }

            Button(action: { userManager.logout() }) {
                Text("logout")
            }.buttonStyle(.bordered)
        }
        .frame(height: 200)
        .overlay(
            VStack {
                Text(detailedMessage)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom)

                Button {
                    UIPasteboard.general.string = debugData
                } label: {
                    Text("Copy debug data")
                }

                Button(action: { errorShowing = false }, label: {
                    Text("OK")
                }).buttonStyle(.bordered)
            }
            .padding()
            .background(Color("background"))
            .border(Color.black)
            .opacity(errorShowing ? 1 : 0)
        )
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
