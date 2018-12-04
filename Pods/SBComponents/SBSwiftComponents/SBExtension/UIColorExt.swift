//
//  UIColorExt.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

public extension UIColor {
    
    public class func sb_random() -> UIColor {
        let r: CGFloat = CGFloat(arc4random()%255)
        let g: CGFloat = CGFloat(arc4random()%255)
        let b: CGFloat = CGFloat(arc4random()%255)
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}
