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

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // http://localhost:8000/chat" 
        // https://growkit.app/chat
        let myURL = URL(string:"https://growkit.app/chat")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "toggleMessageHandler")
    }
}

extension ChatWebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else {
            return
        }

        print(dict)
        hapticFeedback()
    }

    private func hapticFeedback() {
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator().impactOccurred(intensity: 0.7)
        } else {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
}
