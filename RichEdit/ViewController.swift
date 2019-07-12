//
//  ViewController.swift
//  RichEdit
//
//  Created by fay on 2019/7/9.
//  Copyright © 2019 fay. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var width: CGFloat {
        return self.view.frame.size.width
    }
    
    var height: CGFloat{
        return self.view.frame.size.height
    }
    
    var colorHex: String = ""
    var backgroundColorHex: String = ""
    var isFontColor: Bool = false
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration.init()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let userContentController = WKUserContentController.init();
        let weakScriptMessageHandle = WeakScriptMessageDelegate.init(self)
        userContentController.add(weakScriptMessageHandle, name: "logger")
        userContentController.add(weakScriptMessageHandle, name: "actions")
        
        config.userContentController = userContentController
        config.preferences = preferences
        let webView = WKWebView.init(frame: CGRect.zero, configuration: config)
        FauxBarHelper().removeInputAccessoryView(webView: webView)
        return webView;
    }()

    lazy var editToolBar: EditToolBar = {
        let bar = EditToolBar(frame: CGRect(x: 0, y: height, width: width, height: 40))
        bar.delegate = self
        return bar;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(editToolBar)
        setNavigationBarItems()
        loadHTML();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = self.view.bounds
    }

    func loadHTML(){

        let bundlePath = Bundle.main.bundlePath
        let path = "file://\(bundlePath)/resource/index.html"
        guard let url = URL(string: path) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request);
    }
    
    func setNavigationBarItems() {
        let item1 = UIBarButtonItem.init(title: "预览", style: UIBarButtonItem.Style.plain, target: self, action: #selector(preview))
        self.navigationItem.rightBarButtonItem = item1
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardFrameChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func keyBoardFrameChange(_ notifocation: Notification){
        // 1.获取动画执行的时间
        let duration = notifocation.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        // 2.获取键盘最终 Y值
        let endFrame = (notifocation.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let y = endFrame.origin.y
        UIView.animate(withDuration: duration, animations: {
            self.editToolBar.frame = CGRect(x: 0, y: y < self.height ? y-44 : y, width: self.width, height: 44)
        }) { (complete) in
        }
    }
    
    @objc func preview() {
        webView.evaluateJavaScript("getHtml()") { (val, err) in
            if let _val = val as? String {
                let previewVC = PreviewViewController()
                previewVC.htmlContent = _val
                self.navigationController?.pushViewController(previewVC, animated: true)
            }
        }
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let methodName = message.name
        let methodMessage = message.body
        if methodName == "logger" {
            print("js log: \(methodMessage)");
        }else if methodName == "actions" {
            if let actions = methodMessage as? Dictionary<String, Any> {
                editToolBar.updateButtonItemStatus(actions)
            }
        }
    }
}

extension ViewController: EditToolBarDelegate {
    func blur(_ toolBar: EditToolBar) {
        webView.evaluateJavaScript("blur()") { (val, err) in
            self.view.endEditing(true)
            print("val: \(String(describing: val)), err: \(String(describing: err))")
        }
    }
    
    func editToolBar(_ toolBar: EditToolBar, action: String, val: Any?) {
        print("action: \(action)")
        switch action {
            
        case "blod":
            let selected = val as! Bool
            webView.evaluateJavaScript("setBold(\(selected))", completionHandler: nil)
            break
            
        case "italic":
            let selected = val as! Bool
            webView.evaluateJavaScript("setItalic(\(selected))", completionHandler: nil)
            break
            
        case "underline":
            let selected = val as! Bool
            webView.evaluateJavaScript("setUnderline(\(selected))", completionHandler: nil)
            break
            
        case "strike":
            let selected = val as! Bool
            webView.evaluateJavaScript("setStrike(\(selected))", completionHandler: nil)
            break
            
        case "indent-increase":
            webView.evaluateJavaScript("setIndent('+1')", completionHandler: nil)
            break
            
        case "indent-decrease":
            webView.evaluateJavaScript("setIndent('-1')", completionHandler: nil)
            break
            
        case "header":
            var result: Any
            if let selected = val as? Bool, selected {
                result = 2
            }else{
                result = false
            }
            webView.evaluateJavaScript("setHeader(\(result))", completionHandler: nil)
            break
            
        case "center", "right":
            var result: Any
            if let selected = val as? Bool, selected {
                result = action
                webView.evaluateJavaScript("setAlign('\(result)')", completionHandler: nil)
            }else{
                result = false
                webView.evaluateJavaScript("setAlign(\(result))", completionHandler: nil)
            }
            break
            
        case "left":
            webView.evaluateJavaScript("setAlign(\(false))", completionHandler: nil)
            break
            
        case "bullet", "ordered":
            var result: Any
            if let selected = val as? Bool, selected {
                result = action
                webView.evaluateJavaScript("setList('\(result)')", completionHandler: nil)
            }else{
                result = false
                webView.evaluateJavaScript("setList(\(result))", completionHandler: nil)
            }
            break
            
        case "undo":
            webView.evaluateJavaScript("undo()", completionHandler: nil)
            break
            
        case "redo":
            webView.evaluateJavaScript("redo()", completionHandler: nil)
            break
            
        case "image":
            showPickImageVC()
            break
            
        case "color":
            isFontColor = true
            showColorPickVC()
            break
            
        case "background":
            isFontColor = false
            showColorPickVC()
            break
            
        case "sub", "super":
            var result: Any
            if let selected = val as? Bool, selected {
                result = action
                webView.evaluateJavaScript("setScript('\(result)')", completionHandler: nil)
            }else{
                result = false
                webView.evaluateJavaScript("setScript(\(result))", completionHandler: nil)
            }
            break
            
        case "size":
            var result: Any
            if let selected = val as? Bool, selected {
                // small normal large huge
                result = "large"
                webView.evaluateJavaScript("setSize('\(result)')", completionHandler: nil)
            }else{
                result = false
                webView.evaluateJavaScript("setSize(\(result))", completionHandler: nil)
            }
            break
            
        case "code-block":
            var result: Any
            if let selected = val as? Bool, selected {
                result = 1
            }else{
                result = false
            }
            webView.evaluateJavaScript("setCodeblock(\(result))", completionHandler: nil)
            break
            
        case "blockquote":
            var result: Any
            if let selected = val as? Bool, selected {
                result = 1
            }else{
                result = false
            }
            webView.evaluateJavaScript("setBlockquote(\(result))", completionHandler: nil)
            break
            
        case "format-clear":
            webView.evaluateJavaScript("removeAllFormat()", completionHandler: nil)
            break
        default: break
        }
    }
    
    func editFontColor() {
        if isFontColor {
            webView.evaluateJavaScript("setColor('\(colorHex)')", completionHandler: nil)
        }else{
            webView.evaluateJavaScript("setBackgroundColor('\(backgroundColorHex)')", completionHandler: nil)
        }
    }
    
    func insertImage(_ image: UIImage){
        /**
         *  此处直接将image-> base64 插入文件中
         *  正常情况下 在此处获取image -> 上传服务器 -> 获取链接 -> 插入文件中
         *  ag: webView.evaluateJavaScript("insertImage('https://www.xxx.com/image/xxx.png')", completionHandler: nil)
         */
        let image64 = UIImage.corver(image: image) ?? ""
        webView.evaluateJavaScript("insertImage('data:image/png;base64,\(image64)')", completionHandler: nil)
    }
}

extension ViewController: EFColorSelectionViewControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    func showColorPickVC() {
        let colorSelectionController = EFColorSelectionViewController()
        let navCtrl = UINavigationController(rootViewController: colorSelectionController)
        navCtrl.navigationBar.backgroundColor = UIColor.white
        navCtrl.navigationBar.isTranslucent = false
        navCtrl.modalPresentationStyle = UIModalPresentationStyle.popover
        navCtrl.popoverPresentationController?.delegate = self
        navCtrl.popoverPresentationController?.sourceView = self.view
        navCtrl.popoverPresentationController?.sourceRect = self.view.bounds
        navCtrl.preferredContentSize = colorSelectionController.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
        
        colorSelectionController.delegate = self
        colorSelectionController.color = self.view.backgroundColor ?? UIColor.white
        
        if UIUserInterfaceSizeClass.compact == self.traitCollection.horizontalSizeClass {
            let doneBtn: UIBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("完成", comment: ""),
                style: UIBarButtonItem.Style.done,
                target: self,
                action: #selector(ef_dismissViewController(sender:))
            )
            colorSelectionController.navigationItem.rightBarButtonItem = doneBtn
        }
        self.present(navCtrl, animated: true, completion: nil)
    }
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        if let colorHex = color.hexString {
            if isFontColor {
                self.colorHex = colorHex
            }else{
                self.backgroundColorHex = colorHex;
            }
        }
    }
    
    // MARK:- Private
    @objc func ef_dismissViewController(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            [weak self] in
            if let _self = self {
                _self.editFontColor()
                print("EFColorPicker closed.")
            }
        }
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showPickImageVC() {
        let photoPickerViewController:UIImagePickerController = UIImagePickerController()
        photoPickerViewController.sourceType = UIImagePickerController.SourceType.photoLibrary
        photoPickerViewController.delegate = self
        self.present(photoPickerViewController, animated: true, completion: nil)
    }
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.insertImage(selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
}
