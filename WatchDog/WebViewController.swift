//
//  WebView.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 2/11/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import OAuthSwift
import UIKit

typealias WebView = UIWebView // WKWebView

class WebViewController: OAuthWebViewController {

    var targetURL: URL?
    let webView: WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
            self.webView.frame = UIScreen.main.bounds
            self.webView.scalesPageToFit = true
            self.webView.delegate = self
            self.view.addSubview(self.webView)
            loadAddressURL()
          }

    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        self.loadAddressURL()
    }

    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
    
            self.webView.loadRequest(req)
            }
}

// MARK: delegate

    extension WebViewController: UIWebViewDelegate {
        func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            if let url = request.url, url.scheme == "oauth-swift" {
                // Call here AppDelegate.sharedInstance.applicationHandleOpenURL(url) if necessary ie. if AppDelegate not configured to handle URL scheme
                // compare the url with your own custom provided one in `authorizeWithCallbackURL`
                self.dismissWebViewController()
            }
            return true
        }
    }

