//
//  ChatViewWebController.swift
//  
//
//  Created by Khalid Fawal on 2022-10-28.
//

import Foundation
import SwiftUI
import WebKit

class ChatKitWebViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var shouldGoBack: Bool = false
    @Published var title: String = ""

    var url: String

    init(url: String) {
        self.url = url
    }
}

struct ChatKitWebViewContainer: UIViewRepresentable {
    @ObservedObject var webViewModel: ChatKitWebViewModel
    var webView:WKWebView
    func makeCoordinator() -> ChatKitWebViewContainer.Coordinator {
        let a = Coordinator(self, webViewModel)
        self.webView.configuration.userContentController.add(a,name: "observer")
    }

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: webViewModel.url) else {
            return WKWebView()
        }

        let request = URLRequest(url: url)

        let _webView = WKWebView()
        _webView.isOpaque = false
        _webView.backgroundColor = UIColor(Color("Primary"))
        _webView.navigationDelegate = context.coordinator

        _webView.load(request)
        self.webView = _webView
        return _webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if webViewModel.shouldGoBack {
            uiView.goBack()
            webViewModel.shouldGoBack = false
        }
    }
}

extension ChatKitWebViewContainer {
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        @ObservedObject private var webViewModel: ChatKitWebViewModel
        private let parent: ChatKitWebViewContainer

        init(_ parent: ChatKitWebViewContainer, _ webViewModel: ChatKitWebViewModel) {
            self.parent = parent
            self.webViewModel = webViewModel

        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            webViewModel.isLoading = true
           // webView.configuration.userContentController.add(self,name: "observer")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webViewModel.isLoading = false
            webViewModel.title = webView.title ?? ""
            webViewModel.canGoBack = webView.canGoBack
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webViewModel.isLoading = false
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("From WebView GrowKit: ",message.body)
        }
    }
}
