//
//  SBHTTPState.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/6.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import Foundation
import RealReachability

fileprivate let APP_PING_HOST = "www.baidu.com"
fileprivate let APP_CHECK_HOST = "www.qq.com"

public class SBHTTPState {
    
    /// Callback
    public var callback: VoidClosure?
    
    public static let shared = SBHTTPState()
    private init() {
        RealReachability.sharedInstance().hostForPing = APP_PING_HOST
        RealReachability.sharedInstance().hostForCheck = APP_CHECK_HOST
        RealReachability.sharedInstance().autoCheckInterval = 0.3
        RealReachability.sharedInstance().reachability { (status) in
            debugPrint("network status:\(status.rawValue)")
        }
        //TODO:此处可以发送消息给RN组件
        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged), name: NSNotification.Name.realReachabilityChanged, object: nil)
        RealReachability.sharedInstance().startNotifier()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.realReachabilityChanged, object: nil)
    }
    /// network status changed
    @objc private func networkStatusChanged() {
        let status = RealReachability.sharedInstance().currentReachabilityStatus()
        let reachable = (status != .RealStatusNotReachable)
        debugPrint("网络状态变化:\(reachable)")
        callback?()
    }
    /// 是否联通
    public func isReachable() -> Bool {
        let status = RealReachability.sharedInstance().currentReachabilityStatus()
        return status != .RealStatusNotReachable
    }
    /// 是否Wi-Fi
    public func isViaWifi() -> Bool {
        let status = RealReachability.sharedInstance().currentReachabilityStatus()
        return status == .RealStatusViaWiFi
    }
}
