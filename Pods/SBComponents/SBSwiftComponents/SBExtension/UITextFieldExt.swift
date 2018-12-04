//
//  UIKitExts.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

public extension UITextField {
    private struct sb_associatedKeys {
        static var acceptMaxLength = "sb_maxLength"
    }
    public var sb_maxLength: Int {
        set {
            objc_setAssociatedObject(self, &sb_associatedKeys.acceptMaxLength, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let rs = objc_getAssociatedObject(self, &sb_associatedKeys.acceptMaxLength) as? Int {
                return rs
            }
            
            return 0
        }
    }
}
