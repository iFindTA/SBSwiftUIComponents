//
//  UIViewExt.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import SnapKit
import Foundation

public enum SBSceneState: Int {
    case idle
    case empty
    case loading
    case netBroken
}

public extension UIView {
    private struct sb_associatedKeys {
        static var state = "sb_scene_load_key"
        static var indicator = "sb_scene_indicator_key"
    }
    public var appearState: SBSceneState {
        get{
            if let s = objc_getAssociatedObject(self, &sb_associatedKeys.state) as? SBSceneState {
                return s
            }
            return .idle
        }
        set{
            self.update(newValue)
            objc_setAssociatedObject(self, &sb_associatedKeys.state, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func loader() -> UIActivityIndicatorView {
        var acter: UIActivityIndicatorView!
        if let s = objc_getAssociatedObject(self, &sb_associatedKeys.indicator) as? UIActivityIndicatorView {
            acter = s
        } else {
            let a = UIActivityIndicatorView(style: .gray)
            a.hidesWhenStopped = true
            acter = a
            objc_setAssociatedObject(self, &sb_associatedKeys.indicator, a, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return acter
    }
    private func update(_ s: SBSceneState) {
        if s == .idle {
            self.loader().stopAnimating()
        } else if s == .loading {
            let loader = self.loader()
            if loader.superview == nil {
                self.addSubview(loader)
                loader.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                self.layoutIfNeeded()
            }
            self.bringSubviewToFront(loader)
            loader.startAnimating()
        }
    }
    
    public func isVisible() -> Bool {
        guard superview != nil else {
            return false
        }
        guard isHidden == false else {
            return false
        }
        let rect = self.convert(self.frame, from: nil)
        if rect.isNull || rect.isEmpty || rect.equalTo(.zero) {
            return false
        }
        let srect = UIScreen.main.bounds
        guard rect.intersects(srect) == true else {
            return false
        }
        return true
    }
}

extension UIAlertAction {
    private struct sb_associatedKeys {
        static var tag = "sb_alert_action_tag"
    }
    public var sb_tag: Int {
        get{
            if let s = objc_getAssociatedObject(self, &sb_associatedKeys.tag) as? Int {
                return s
            }
            return 0
        }
        set{
            objc_setAssociatedObject(self, &sb_associatedKeys.tag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
