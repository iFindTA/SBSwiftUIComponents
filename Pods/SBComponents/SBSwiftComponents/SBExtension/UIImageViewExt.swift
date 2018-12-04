//
//  UIImageViewExt.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

public extension UIImageView {
    public func sb_setCorner(_ size: CGFloat = 8) {
        //异步绘制图像
        DispatchQueue.global().async(execute: {
            //1.建立上下文
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
            defer{
                UIGraphicsEndImageContext()
            }
            //获取当前上下文
            let ctx = UIGraphicsGetCurrentContext()
            
            //设置填充颜色
            UIColor.white.setFill()
            UIRectFill(self.bounds)
            
            //2.添加圆及裁切
            ctx?.addEllipse(in: self.bounds)
            //裁切
            ctx?.clip()
            
            //3.绘制图像
            self.draw(self.bounds)
            
            //4.获取绘制的图像
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            DispatchQueue.main.async(execute: {
                self.image = image
            })
        })
    }
}
