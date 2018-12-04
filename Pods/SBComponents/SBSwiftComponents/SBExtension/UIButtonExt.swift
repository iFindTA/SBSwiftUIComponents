//
//  UIButtonExt.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

public enum ButtonImagePosition {
    case left
    case right
    case top
    case bottom
}

public extension UIButton {
    private struct sb_associatedKeys {
        static var acceptEventInterval = "sb_acceptEventInterval"
        static var acceptEventTime = "sb_acceptEventTime"
        static var busyState = "sb_busyState"
    }
    
    public var sb_busyState: Bool {
        get {
            if let busy = objc_getAssociatedObject(self, &sb_associatedKeys.busyState) as? Bool {
                return busy
            }
            return false
        }
        
        set {
            objc_setAssociatedObject(self, &sb_associatedKeys.busyState, newValue as Bool, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var sb_acceptEventInterval: TimeInterval {
        get {
            if let acceptEventInterval = objc_getAssociatedObject(self, &sb_associatedKeys.acceptEventInterval) as? TimeInterval {
                return acceptEventInterval
            }
            return 1.0
        }
        
        set {
            objc_setAssociatedObject(self, &sb_associatedKeys.acceptEventInterval, newValue as TimeInterval, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var sb_acceptEventTime: TimeInterval {
        get {
            if let acceptEventTime = objc_getAssociatedObject(self, &sb_associatedKeys.acceptEventTime) as? TimeInterval {
                return acceptEventTime
            }
            return 0
        }
        
        set {
            objc_setAssociatedObject(self, &sb_associatedKeys.acceptEventTime, newValue as TimeInterval, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func sb_fixImagePosition(_ position: ButtonImagePosition, spacing: CGFloat=5) {
        guard let image = self.imageView?.image else {
            return
        }
        guard let title = self.titleLabel else {
            return
        }
        let imageSize = image.size
        let titleSize = title.bounds.size
        let imgW: CGFloat = imageSize.width
        let imgH: CGFloat = imageSize.height
        let orgLabW: CGFloat = titleSize.width
        let orgLabH: CGFloat = titleSize.height
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let trueSize: CGSize = title.sizeThatFits(maxSize)
        let trueLabW: CGFloat = trueSize.width
        
        //image中心移动的x距离
        let imageOffsetX: CGFloat = orgLabW/2
        //image中心移动的y距离
        let imageOffsetY: CGFloat = orgLabH/2 + spacing/2
        //label左边缘移动的x距离
        let labelOffsetX1: CGFloat = imgW/2 - orgLabW/2 + trueLabW/2
        //label右边缘移动的x距离
        let labelOffsetX2: CGFloat = imgW/2 + orgLabW/2 - trueLabW/2
        //label中心移动的y距离
        let labelOffsetY: CGFloat = imgH/2 + spacing/2
        
        switch (position) {
        case .left:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2);
            break;
            
        case .right:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, orgLabW + spacing/2, 0, -(orgLabW + spacing/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imgW + spacing/2), 0, imgW + spacing/2);
            break;
            
        case .top:
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX1, -labelOffsetY, labelOffsetX2);
            break;
            
        case .bottom:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX1, labelOffsetY, labelOffsetX2);
            break;
        }
    }
}
