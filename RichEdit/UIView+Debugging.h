//
//  UIView+Debugging.h
//  RichEdit
//
//  Created by fay on 2021/3/19.
//  Copyright © 2021 fay. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Debugging)
// 用于测试打印层级关系
- (id)recursiveDescription;

@end

NS_ASSUME_NONNULL_END
