//
//  ChatWebViewController.swift
//  
//
//  Created by Khalid Fawal on 2022-10-28.
//

import Foundation
import SwiftUI
import WebKit


class ChatWebViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!

    
    // http://localhost:8000/chat
    // https://growkit.app/chat
    public var webviewURL: String = "https://growkit.app/chat"
    public var chatSequence: ChatSequence
    public var theme: ChatTheme

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color("Primary"))
        webView.scrollView.showsVerticalScrollIndicator = false
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let myURL = URL(string: webviewURL)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "toggleMessageHandler")
    }

    func closeChatView() {
        dismiss(animated: true)
    }
}

extension ChatWebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }

        print(dict)
        hapticFeedback()
        do {
            print(dict["message"])
        }catch {
        }

    }

    private func hapticFeedback() {
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator().impactOccurred(intensity: 0.7)
        } else {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
}
