//
//  StringExt.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

// MARK: - String Extension
public extension String {
    public static func available(_ info: String?, replace: String="") -> String {
        guard let i = info, i.count > 0 else {
            return replace
        }
        return i
    }
    public func sb_matchRegex(_ p: String) -> Bool {
        guard self.isEmpty == false else {
            return false
        }
        let predicate = NSPredicate(format: "SELF MATCHES %@", p)
        return predicate.evaluate(with: self)
    }
    public func sb_size(_ width: CGFloat, font: UIFont) -> CGSize {
        guard self.count > 0 else {
            return .zero
        }
        let bounds = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return bounds.size
    }
}
