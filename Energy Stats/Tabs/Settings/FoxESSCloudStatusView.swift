//
//  FoxESSCloudStatusView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 31/07/2023.
//

import SafariServices
import SwiftUI
import WebKit

#if os(iOS)
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
#endif

#if os(macOS)
struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> NSViewType {
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }
}
#endif
