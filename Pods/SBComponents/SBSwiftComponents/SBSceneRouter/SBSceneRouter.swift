//
//  SBSceneRouter.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/5.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

// MARK: - protocols
public protocol SBScenePathable {
    func route() -> String
}
extension SBScenePathable {
    public func route() -> String {
        return "SB404"
    }
}
fileprivate enum SBNotFound: String, SBScenePathable {
    case notFound
}
public protocol SBSceneRouteable {
    static func __init(_ params: SBParameter?) -> UIViewController
}

// MARK: - 场景路由
public class SBSceneRouter {
    public class func route2(_ path: SBScenePathable, params: SBParameter?=nil, space: String?=nil, push: Bool = true, replace: Bool = false, animate: Bool = true, completion: (() -> Void)? = nil) -> BaseError? {
        //assemble class for route
        let clsRoute = path.route()
        var routePath = ""
        if let spaceName = space {
            routePath = spaceName + "." + clsRoute
        } else {
            let spaceName = Bundle.main.infoDictionary!["CFBundleExecutable"] as? String
            let s = String.available(spaceName, replace: "SBComponents")
            routePath = s + "." + clsRoute
        }
        guard let cls = NSClassFromString(routePath) else {
            let error = BaseError.init("route path error!")
            RouterKit.route2NotFound(err: error)
            return error
        }
        
        guard let destCls = cls as? SBSceneRouteable.Type else {
            let error = BaseError.init("rclass does not conform Routable protocol!")
            RouterKit.route2NotFound(err: error)
            return error
        }
        //尝试初始化控制器
        let profile = destCls.__init(params)
        //profile.hidesBottomBarWhenPushed = true
        
        //转场 push or present
        //找到栈顶profile
        guard let topestProfile = RouterKit.topestProfile() else {
            //如果未找到栈顶 则直接pop
            let navigationProfile = RouterKit.rootableNavigationProfile()
            navigationProfile?.pushViewController(profile, animated: true)
            let error = BaseError.init("未找到栈顶profile")
            return error
        }
        guard let curNavigator = topestProfile.navigationController else {
            //如果未找到当前的navigation
            let navigator = BaseNavigationProfile(rootViewController: profile)
            navigator.setNavigationBarHidden(true, animated: true)
            //navigator.sj_gestureType = .full
            topestProfile.present(navigator, animated: true, completion: nil)
            let error = BaseError.init("未找到栈顶profile的navigator")
            return error
        }
        guard push == true else {
            //present
            let navigator = BaseNavigationProfile(rootViewController: profile)
            navigator.setNavigationBarHidden(true, animated: true)
            //navigator.sj_gestureType = .full
            curNavigator.present(navigator, animated: true, completion: nil)
            return nil
        }
        
        //whether replace current profile
        guard replace == false else {
            let stacks = curNavigator.viewControllers
            let counts = stacks.count
            var newStacks = [UIViewController]()
            for (idx, p) in stacks.enumerated() {
                if idx <= counts - 2 {
                    newStacks.append(p)
                }
            }
            newStacks.append(profile)
            curNavigator.setViewControllers(newStacks, animated: animate)
            return nil
        }
        curNavigator.pushViewController(profile, animated: animate)
        return nil
    }
    
    /// 返回
    public class func back(_ to: String? = nil, excute: VoidClosure? = nil) {
        //找到栈顶profile
        guard let topestProfile = RouterKit.topestProfile() else {
            //如果未找到栈顶 则直接pop
            let navigationProfile = RouterKit.rootableNavigationProfile()
            UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {
                navigationProfile?.popViewController(animated: true)
            }) { (finish) in
                excute?()
            }
            return
        }
        guard let curNavigator = topestProfile.navigationController else {
            //如果未找到当前的navigation 则默认root pop action
            let navigationProfile = RouterKit.rootableNavigationProfile()
            UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {
                navigationProfile?.popViewController(animated: true)
            }) { (finish) in
                excute?()
            }
            return
        }
        //是否返回到指定scene
        guard let destScene = to else {
            curNavigator.defaultGoBack(excute)
            return
        }
        let stacks = curNavigator.viewControllers
        var newStacks = [UIViewController]()
        for (_, p) in stacks.enumerated() {
            let clsString = String(describing: type(of: p))
            if clsString == destScene {
                newStacks.append(p)
                break
            }
            newStacks.append(p)
        }
        UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {
            curNavigator.setViewControllers(newStacks, animated: true)
        }) { (finish) in
            if finish {
                excute?()
            }
        }
    }
    
    public class func dismiss(_ excute: VoidClosure? = nil) {
        //找到栈顶profile
        guard let topestProfile = RouterKit.topestProfile() else {
            //如果未找到栈顶 则直接pop
            let navigationProfile = RouterKit.rootableNavigationProfile()
            UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {
                navigationProfile?.popViewController(animated: true)
            }) { (finish) in
                excute?()
            }
            return
        }
        guard let curNavigator = topestProfile.navigationController else {
            //如果未找到当前的navigation 则默认root pop action
            let navigationProfile = RouterKit.rootableNavigationProfile()
            UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {
                navigationProfile?.popViewController(animated: true)
            }) { (finish) in
                excute?()
            }
            return
        }
        curNavigator.dismiss(animated: true, completion: excute)
    }
}

// MARK: - 场景Kit
public class RouterKit {
    public class func topViewController(rootProfile: UIViewController) -> UIViewController {
        if rootProfile.isKind(of: UITabBarController.self) {
            let tabBarProfile = rootProfile as! UITabBarController
            return topViewController(rootProfile:tabBarProfile.selectedViewController!)
        }
        if rootProfile.isKind(of: UINavigationController.self) {
            let navigationProfile = rootProfile as! UINavigationController
            return topViewController(rootProfile:navigationProfile.visibleViewController!)
        }
        if rootProfile.presentedViewController != nil {
            return topViewController(rootProfile:rootProfile.presentedViewController!)
        }
        return rootProfile
    }
    
    public class func topestProfile() -> UIViewController? {
        guard let rootProfile = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        //找到目前正在显示的栈顶profile
        return topViewController(rootProfile: rootProfile)
    }
    
    public class func rootableNavigationProfile() -> UINavigationController? {
        guard let rootProfile = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        //找到目前正在显示的栈顶profile
        guard rootProfile.isKind(of: UINavigationController.self) else {
            return nil
        }
        let navigationProfile = rootProfile as! UINavigationController
        return navigationProfile
    }
    
    /// 处理错误
    public class func route2NotFound(err: BaseError?) {
        guard let error = err else {
            return
        }
        debugPrint(error.localizedDescription)
        //可以转到404页面
        _ = SBSceneRouter.route2(SBNotFound.notFound, params: nil, space: "SBComponents")
    }
}
// MARK: - Base Navigation手动扩展
extension UINavigationController {
    public func rooter() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    public func defaultGoBack(_ excute: VoidClosure? = nil) {
        let statcks = self.viewControllers
        if statcks.count <= 1 {
            guard let rooter = self.rooter() else {
                self.dismiss(animated: true, completion: excute)
                return
            }
            if self != rooter {
                self.dismiss(animated: true, completion: excute)
            }
        } else {
            // 初始化动画的持续时间，类型和子类型
            UIView.animate(withDuration: Macros.APP_ANIMATE_INTERVAL, animations: {[weak self]in
                self?.popViewController(animated: true)
            }) { (finish) in
                excute?()
            }
        }
    }
}
