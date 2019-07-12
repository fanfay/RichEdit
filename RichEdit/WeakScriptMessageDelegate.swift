//
//  WeakScriptMessageDelegate.swift
//  RichEdit
//
//  Created by fay on 2019/7/9.
//  Copyright © 2019 fay. All rights reserved.
//

import UIKit
import WebKit

class WeakScriptMessageDelegate: NSObject, WKScriptMessageHandler{
    weak var scriptDelegate: WKScriptMessageHandler?
    
    init(_ scriptDelegate: WKScriptMessageHandler) {
        self.scriptDelegate = scriptDelegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate?.userContentController(userContentController, didReceive: message)
    }
    
    deinit {
        print("WeakScriptMessageDelegate is deinit")
    }
}
