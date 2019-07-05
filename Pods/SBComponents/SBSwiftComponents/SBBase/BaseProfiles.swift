//
//  BaseProfiles.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation
import PPBadgeViewSwift

// MARK: - Base Profile
open class BaseProfile: UIViewController {
    /// - override
    deinit {
        debugPrint("profile:\(type(of: self)) 析构")
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
        guard #available(iOS 11.0, *) else {
            automaticallyAdjustsScrollViewInsets = false
            return
        }
    }
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        guard #available(iOS 11.0, *) else {
            automaticallyAdjustsScrollViewInsets = false
            return
        }
    }
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    override open var shouldAutorotate: Bool {
        return false
    }
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    /// - Variables
    public lazy var navigationBar: BaseNavigationBar = {
        let n = BaseNavigationBar()
        let tintColor = AppColor.COLOR_NAVIGATOR_TINT
        let barTintColor = UIColor.white //影响背景
        let font = AppFont.pingFangSC(AppFont.SIZE_LARGE_TITLE)
        n.barStyle = .black
        let bgImg = generateBgImage(barTintColor);
        n.setBackgroundImage(bgImg, for: .default)
        n.shadowImage = UIImage()
        n.barTintColor = barTintColor
        n.tintColor = tintColor
        n.isTranslucent = false
        n.titleTextAttributes = {[
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor:tintColor
            ]}()
        return n
    }()
    
    /// - private methods
    private func generateBgImage(_ color: UIColor) -> UIImage {
        let rect = CGRect(x:0,y:0,width:1,height:1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    private func fixedIssue() {
        let s = BaseScrollView(frame: .zero)
        view.addSubview(s)
        s.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
    }
    
    /// - Inner-Methods
    @objc public func defaultGobackStack() {
        guard self.isBeingPresented else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    public func whetherContain(_ cls: String) -> Bool {
        guard let navi = self.navigationController else {
            return false
        }
        let stacks: [UIViewController] = navi.viewControllers
        var contain: Bool = false
        for (_, p) in stacks.enumerated() {
            let clsString = String(describing: type(of: p))
            if clsString == cls {
                contain = true
                break
            }
        }
        return contain
    }
    open override func viewDidLoad() {
        super.viewDidLoad();fixedIssue()
        view.backgroundColor = UIColor.white
    }
    
    /// network request
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllRequest()
        BaseLoading.shared.hide()
        resetBusy()
    }
    private func stopAllRequest() {
        let this = NSStringFromClass(type(of: self))
        let tmp = this as NSString
        guard tmp.range(of: ".").location == NSNotFound else {
            let range = tmp.range(of: ".", options: .backwards)
            let nr = tmp.substring(with: NSMakeRange(range.location+1, this.count-range.location-range.length))
            SBHTTPRouter.shared.cancel(nr)
            return
        }
        SBHTTPApi.shared.cancel(this)
        SBHTTPRouter.shared.cancel(this)
    }
    
    /// vars for busy
    open var isBusy: Bool = false
    public func resetBusy() {
        isBusy = false
    }
}

// MARK: - Base NavigationController
open class BaseNavigationProfile: UINavigationController {
    /// override
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        guard let top = self.topViewController else {
            return .default
        }
        return top.preferredStatusBarStyle
    }
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override open var shouldAutorotate: Bool {
        return (topViewController?.shouldAutorotate)!
    }
    //支持旋转的方向有哪些
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return (topViewController?.supportedInterfaceOrientations)!
    }
    //控制 vc present进来的横竖屏和进入方向 ，支持的旋转方向必须包含改返回值的方向 （详细的说明见下文）
    override open var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return (topViewController?.preferredInterfaceOrientationForPresentation)!
    }
}

// MARK: - Base TabBarController
open class BaseTabBarProfile: UITabBarController {
    
    /// override
    //是否跟随屏幕旋转
    override open var shouldAutorotate : Bool {
        return (selectedViewController?.shouldAutorotate)!
    }
    //支持旋转的方向有哪些
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return (selectedViewController?.supportedInterfaceOrientations)!
    }
    //控制 vc present进来的横竖屏和进入方向 ，支持的旋转方向必须包含改返回值的方向 （详细的说明见下文）
    override open var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return (selectedViewController?.preferredInterfaceOrientationForPresentation)!
    }
    
    /// hide bar
    private func isTabBarHidden() -> Bool {
        return self.tabBar.isHidden
    }
    
    public func hideBar(_ hide: Bool, animate: Bool) {
        guard hide != self.isTabBarHidden() else {
            return
        }
        var transitionView: UIView?
        if let first = self.view.subviews.first, first.isKind(of: UITabBar.self) {
            transitionView = first
        } else {
            transitionView = self.view.subviews.first
        }
        if !hide {
            self.tabBar.isHidden = hide
        }
        self.sb_isTabBarAnimating = true
        
        UIView.animate(withDuration: animate ? TimeInterval(UINavigationController.hideShowBarDuration) : 0, delay: 0, options: .allowUserInteraction, animations: {
            var tabBarTop: CGFloat = 0
            let viewFrame = self.view.convert(self.view.bounds, to: self.tabBar.superview)
            if hide {
                tabBarTop = viewFrame.origin.y + viewFrame.size.height
                transitionView?.frame = self.view.bounds
            } else {
                let bounds = self.view.bounds
                let selfHeight = self.tabBar.frame.size.height
                tabBarTop = viewFrame.origin.y + viewFrame.size.height - selfHeight
                transitionView?.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height - selfHeight)
            }
            var frame:CGRect = self.tabBar.frame
            frame.origin.y = tabBarTop
            self.tabBar.frame = frame
        }) { [weak self](f: Bool) in
            if hide {
                self?.tabBar.isHidden = true
            }
            self?.sb_isTabBarAnimating = false
        }
    }
}
public extension BaseTabBarProfile {
    private struct sb_tabbarHiddenKeys {
        static var sb_isTabBarAnimating = "sb_isTabBarAnimating"
    }
    private var sb_isTabBarAnimating: Bool {
        get {
            return objc_getAssociatedObject(self, &sb_tabbarHiddenKeys.sb_isTabBarAnimating) as! Bool
        }
        set {
            objc_setAssociatedObject(self, &sb_tabbarHiddenKeys.sb_isTabBarAnimating, newValue as Bool, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func setBadge(_ badge: Int, for index: Int) {
        guard let items = self.tabBar.items, index < items.count else {
            return
        }
        if badge < 0 {
            items[index].pp.hiddenBadge()
        } else if badge == 0 {
            items[index].pp.addDot(color: UIColor.red)
        } else {
            items[index].pp.addBadge(number: badge)
        }
    }
}
