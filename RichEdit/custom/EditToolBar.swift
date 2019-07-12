//
//  EditToolBar.swift
//  RichEdit
//
//  Created by fay on 2019/7/9.
//  Copyright © 2019 fay. All rights reserved.
//

import UIKit

protocol EditToolBarDelegate: NSObjectProtocol {
    func blur(_ toolBar: EditToolBar);
    func editToolBar(_ toolBar: EditToolBar, action: String, val: Any?)
}

class EditToolBar: UIView, UIScrollViewDelegate {
    
    weak var delegate: EditToolBarDelegate?
    
    var barItems: NSArray = []
    var barButtons: NSMutableArray = []
    var barItemsIndex: Dictionary<String, Int> = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        loadConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        layer.shadowColor = UIColor.init(hexString: "#eeeeee").cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 0.8
        backgroundColor = UIColor.white
    }
    
    func loadConfiguration() {
        guard let path = Bundle.main.path(forResource: "EditAction", ofType: "json") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do{
            let data = try Data(contentsOf: url)
            let jsonData: Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            barItems = jsonData as! NSArray
            setupSubViews()
        }catch let error as Error? {
            print("读取本地数据出现错误!",error ?? "")
        }
    }
    
    func setupSubViews() {
        
        let itemSpace: CGFloat = 6
        let itemWidth: CGFloat = 44
        let width = self.frame.size.width
        var maxX: CGFloat = 0;
        
        let container = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: width - itemWidth, height: itemWidth))
        container.showsHorizontalScrollIndicator = false
        container.delegate = self
        addSubview(container)
        
        let closeButton = EditButton.init(frame: CGRect(x: width - itemWidth, y: 0, width: itemWidth, height: itemWidth))
        closeButton.action = "close"
        closeButton.addTarget(self, action: #selector(blur), for: .touchUpInside)
        closeButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        closeButton.setImage(UIImage(named: "descend"), for: .normal)
        addSubview(closeButton)
     
        for (index, item) in barItems.enumerated() {
            if let _item = item as? Dictionary<String, String> {
                let itemButton = EditButton.init(frame: CGRect(x: (itemSpace + itemWidth) * CGFloat(index) + itemSpace, y: 0, width: itemWidth, height: itemWidth))
                itemButton.tag = index
                itemButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
                itemButton.setImage(UIImage(named: _item["image"]!), for: .normal)
                itemButton.setImage(UIImage(named: _item["selectImage"]!), for: .selected)
                itemButton.action = _item["action"]
                itemButton.addTarget(self, action: #selector(operation(_:)), for: .touchUpInside)
                container.addSubview(itemButton)
                maxX = itemButton.frame.maxX
                barButtons.add(itemButton)
                barItemsIndex[_item["action"]!] = index
            }
        }
        print("maxY: ", maxX);
        container.contentSize = CGSize.init(width: maxX + itemSpace, height: itemWidth)
    }
    
    @objc func blur() {
        if let _delegate = delegate {
            _delegate.blur(self)
        }
    }
    
    
    /// 按钮点击事件
    ///
    /// - Parameter item: item
    @objc func operation(_ item: EditButton){
        item.isSelected = !item.isSelected

        if let _delegate = delegate {
            if item.action == "background" || item.action == "color" {
                _delegate.editToolBar(self, action: item.action ?? "", val: item.isSelected)
            } else if item.action == "size" {
                _delegate.editToolBar(self, action: item.action ?? "", val: item.isSelected)
            } else{
                _delegate.editToolBar(self, action: item.action ?? "", val: item.isSelected)
            }
        }
    }
    
    
    /// 更新操作按钮状态
    ///
    /// - Parameter params: js端更新参数
    func updateButtonItemStatus(_ params: Dictionary<String, Any>) {
        barButtons.forEach { (item) in
            if let _item = item as? UIButton {
                _item.isSelected = false
            }
        }
        
        for key in params.keys {
            var index = 0;
            if key == "list" ||  key == "align" || key == "script" {
                if let val = params[key] as? String {
                    index = barItemsIndex[val] ?? 0
                }
            }else {
                if let _index = barItemsIndex[key] {
                    index = _index;
                }
            }
            
            if let barItem = barButtons[index] as? UIButton {
                barItem.isSelected = true
            }
        }
    }
}


class EditButton: UIButton {
    var action: String?
}

