//
//  PerviewViewController.swift
//  RichEdit
//
//  Created by fay on 2019/7/12.
//  Copyright © 2019 fay. All rights reserved.
//

import UIKit
import WebKit

class PreviewViewController: UIViewController {

    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration.init()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        let webView = WKWebView.init(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self
        return webView
    }()
    
    var htmlContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        loadHTML()
    }
    
    func loadHTML() {
        let bundlePath = Bundle.main.bundlePath
        let path = "file://\(bundlePath)/resource/preview.html"
        guard let url = URL(string: path) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request);
    }
    
    func setContent() {
        guard htmlContent != nil else {
            return
        }
        
        webView.evaluateJavaScript("insertContent('\(htmlContent!)')") { (val, err) in
            print("val: \(val ?? ""), err: \(String(describing: err))")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

}

extension PreviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 禁止webview长按弹出menuControl
        self.webView.evaluateJavaScript(
            "document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        self.webView.evaluateJavaScript(
            "document.documentElement.style.webkitUserSelect='none';",
            completionHandler: nil)
        
        self.setContent()
    }
}
