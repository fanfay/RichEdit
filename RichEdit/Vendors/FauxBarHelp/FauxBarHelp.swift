//
//  FauxBarHelp.swift
//  RichEdit
//
//  Created by fay on 2019/7/12.
//  Copyright © 2019 fay. All rights reserved.
//

import Foundation
import WebKit
import UIKit

final class FauxBarHelper: NSObject {
    @objc var inputAccessoryView: AnyObject? { return nil }
    
    func removeInputAccessoryView(webView: WKWebView) {
        var targetView: UIView? = nil
        
        for view in webView.scrollView.subviews {
            if String(describing: type(of: view)).hasPrefix("WKContent") {
                targetView = view
            }
        }
        
        guard let target = targetView else { return }
        
        let noInputAccessoryViewClassName = "\(target.superclass!)_NoInputAccessoryView"
        var newClass: AnyClass? = NSClassFromString(noInputAccessoryViewClassName)
        if newClass == nil {
            let targetClass: AnyClass = object_getClass(target)!
            newClass = objc_allocateClassPair(targetClass, noInputAccessoryViewClassName.cString(using: String.Encoding.ascii)!, 0)
        }
        
        let originalMethod = class_getInstanceMethod(FauxBarHelper.self, #selector(getter: FauxBarHelper.inputAccessoryView))
        class_addMethod(newClass!.self, #selector(getter: FauxBarHelper.inputAccessoryView), method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        object_setClass(target, newClass!)
    }
}
