//
//  BundleExt.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import Foundation

public extension Bundle {
    public class func sb_displayName() -> String? {
        guard let bundleMap = Bundle.main.infoDictionary else {
            return ""
        }
        return bundleMap["CFBundleDisplayName"] as? String
    }
    
    public class func sb_bunldeIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }
    
    public class func sb_buildVersion() -> String {
        guard let bundleMap = Bundle.main.infoDictionary else {
            return "100"
        }
        let build = bundleMap[kCFBundleVersionKey as String] as! String
        return build
    }
    
    public class func sb_appVersion() -> String {
        guard let bundleMap = Bundle.main.infoDictionary else {
            return "1.0"
        }
        let build = bundleMap["CFBundleShortVersionString" as String] as! String
        return build
    }
}
