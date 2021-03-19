//
//  RichEditorWebView.swift
//  RichEdit
//
//  Created by fay on 2021/3/19.
//  Copyright © 2021 fay. All rights reserved.
//

import Foundation
import WebKit

class RichEditorWebView: WKWebView {

    var accessoryView: UIView?

    override var inputAccessoryView: UIView? {
        // remove/replace the default accessory view
        return accessoryView
    }

}
