//
//  Activities.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/12.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit

public class SBActivity: UIActivity {
    var URLToOpen: URL?
    var schemePrefix: String?
    
    override public var activityType : UIActivity.ActivityType? {
        let typeArray = "\(type(of: self))".components(separatedBy: ".")
        let _type: String = typeArray[typeArray.count-1]
        return UIActivity.ActivityType(rawValue: _type)
    }
    
    override public var activityImage : UIImage {
        if let type = activityType?.rawValue {
            return WebBrowser.bundledImage(named: "\(type)")!
        } else {
            assert(false, "Unknow type")
            return UIImage()
        }
    }
    
    override public func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if activityItem is URL {
                URLToOpen = activityItem as? URL
            }
        }
    }
}

public class SBActivitySafari: SBActivity {
    override public var activityTitle : String {
        return NSLocalizedString("Open in Safari", tableName: "SBWebBrowser", comment: "")
    }
    
    override public func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activityItem in activityItems {
            if let activityItem = activityItem as? URL, UIApplication.shared.canOpenURL(activityItem) {
                return true
            }
        }
        return false
    }
    
    override public func perform() {
        //let completed: Bool = UIApplication.shared.openURL(URLToOpen! as URL)
        //activityDidFinish(completed)
        UIApplication.shared.open(URLToOpen!, options: [:]) { [weak self](finished) in
            self?.activityDidFinish(finished)
        }
    }
}

public class SBActivityChrome: SBActivity {
    override public var activityTitle : String {
        return NSLocalizedString("Open in Chrome", tableName: "SBWebBrowser", comment: "")
    }
    
    override public func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for activityItem in activityItems {
            if activityItem is URL, UIApplication.shared.canOpenURL(URL(string: "googlechrome://")!) {
                return true;
            }
        }
        return false;
    }
    
    override public func perform() {
        let inputURL: URL! = URLToOpen as URL?
        let scheme: String! = inputURL.scheme
        
        // Replace the URL Scheme with the Chrome equivalent.
        var chromeScheme: String? = nil;
        if scheme == "http" {
            chromeScheme = "googlechrome"
        } else if scheme == "https" {
            chromeScheme = "googlechromes"
        }
        
        // Proceed only if a valid Google Chrome URI Scheme is available.
        if chromeScheme != nil {
            let absoluteString: NSString! = inputURL!.absoluteString as NSString?
            let rangeForScheme: NSRange! = absoluteString.range(of: ":")
            let urlNoScheme: String! = absoluteString.substring(from: rangeForScheme.location)
            let chromeURLString: String! = chromeScheme!+urlNoScheme
            let chromeURL: URL! = URL(string: chromeURLString)
            // Open the URL with Chrome.
            //UIApplication.shared.openURL(chromeURL)
            UIApplication.shared.open(chromeURL, options: [:], completionHandler: nil)
        }
    }
}
