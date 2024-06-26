//
//  File.swift
//  
//
//  Created by Jianwei Ciou on 2024/3/10.
//
import SwiftUI
import WebKit

@available(iOS 13.0, *)
struct WebViewContainer: UIViewRepresentable {
    @ObservedObject var webViewModel: WebViewModel
 
    func makeCoordinator() -> WebViewContainer.Coordinator {
        Coordinator(self, webViewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.webViewModel.url) else {
            return WKWebView()
        }

        let request = URLRequest(url: url)
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(request)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if webViewModel.shouldGoBack {
            uiView.goBack()
            webViewModel.shouldGoBack = false
        }
    }
}


@available(iOS 13.0, *)
extension WebViewContainer {
    class Coordinator: NSObject, WKNavigationDelegate {
        @ObservedObject private var webViewModel: WebViewModel
        private let parent: WebViewContainer

        init(_ parent: WebViewContainer, _ webViewModel: WebViewModel) {
            self.parent = parent
            self.webViewModel = webViewModel
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webViewModel.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewModel.isLoading = false
            webViewModel.title = webView.title ?? ""
            webViewModel.canGoBack = webView.canGoBack
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webViewModel.isLoading = false
        }
    }
}
