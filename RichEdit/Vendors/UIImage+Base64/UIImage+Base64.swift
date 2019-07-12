//
//  UIImage+Base64.swift
//  RichEdit
//
//  Created by fay on 2019/7/12.
//  Copyright © 2019 fay. All rights reserved.
//

import UIKit

extension UIImage {
    class func corver(imageBase64 imageStr: String) -> UIImage? {
        guard let data = Data.init(base64Encoded: imageStr, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
            return nil
        }
        
        let image = UIImage.init(data: data)
        return image
    }
    
    class func corver(image: UIImage) -> String? {
        guard let imgData = UIImage.jpegData(image)(compressionQuality: 1.0) else {
            return nil
        }
        
        let base64 = imgData.base64EncodedString(options: [])
        return base64
    }
}
