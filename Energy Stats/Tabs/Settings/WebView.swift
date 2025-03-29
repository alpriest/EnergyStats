//
//  FoxESSCloudStatusView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 31/07/2023.
//

import SwiftUI
import WebKit
import SafariServices

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
