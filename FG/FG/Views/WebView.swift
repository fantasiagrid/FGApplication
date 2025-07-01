//
//  WebView.swift
//  FG
//
//  Created by 윤서진 on 6/25/25.
//

import SwiftUI
import WebKit

struct WebContentView: View {
    @State private var currentURL: URL = URL(string: "https://www.youtube.com/shorts/pHINXFbqjR8")!

    var body: some View {
        WebView(url: currentURL) { newURL in
            print("🌐 URL Changed to: \(newURL)")
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let onURLChange: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onURLChange: onURLChange)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onURLChange: (URL) -> Void
        var enterTime: Date?

        init(onURLChange: @escaping (URL) -> Void) {
            self.onURLChange = onURLChange
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url {
                print("✅ Loaded URL: \(url)")
                enterTime = Date()
                onURLChange(url)
            }
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            if let enter = enterTime {
                let duration = Date().timeIntervalSince(enter)
                print("🕒 Stayed for \(duration) seconds")
            }
        }
    }
}
