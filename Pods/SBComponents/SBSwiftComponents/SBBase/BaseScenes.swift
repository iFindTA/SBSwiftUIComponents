//
//  BaseScenes.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

//MARK: - 全局布局定义变量
public let HorizontalOffset = AppSize.WIDTH_MARGIN
public let HorizontalOffsetMid = AppSize.WIDTH_MARGIN*1.5
public let HorizontalOffsetMAX = AppSize.WIDTH_BOUNDARY
public let SeperatorBgColor = RGBA(r: 244, g: 243, b: 245, a: 1)
public let ClearBgColor = UIColor(white: 0, alpha: 0.3)

// MARK: - UIButton类
public class BaseButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public init(type buttonType: UIButtonType) {
        super.init(frame: .zero)
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let preEventStamp = self.sb_acceptEventTime
        let duration = self.sb_acceptEventInterval
        let curEventStamp = Date().timeIntervalSince1970
        let whetherBusy = self.sb_busyState
        if abs(preEventStamp - curEventStamp) > duration && whetherBusy == false {
            super.touchesBegan(touches, with: event)
        }
        self.sb_acceptEventTime = curEventStamp
    }
    
    public var extendTag: Int = 0//扩展的属性 方便操作
}

// MARK: - UILbel类
public class BaseLabel: UILabel {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.white
    }
}

// MARK: - UIImageView类
public class BaseImageView: UIImageView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentMode = .scaleAspectFill
        backgroundColor = UIColor.white
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - UIScrollView类
public class BaseScrollView: UIScrollView {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
}
public extension BaseScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesCancelled(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}

// MARK: - UITableView 类
public class BaseTableView: UITableView {
    /// callback
    public var callback: VoidClosure?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
}
public extension BaseTableView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesCancelled(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}

// MARK: - UITableViewCell
open class BaseCell: UITableViewCell {
    public lazy var scene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    public lazy var iconScene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    public lazy var textScene: BaseScene = {
        let s = BaseScene(frame: .zero)
        return s
    }()
    public lazy var iconView: BaseImageView = {
        let s = BaseImageView(frame: .zero)
        return s
    }()
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(scene)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        scene.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
    }
}

// MARK: - UITextField
public class BaseTextField: UITextField {
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        addTarget(self, action: #selector(editingDidChanged(_:)), for: .editingChanged)
        editingDidChanged(self)
    }
    @objc func editingDidChanged(_ textFiled: UITextField) {
        guard let text = textFiled.text else {
            return
        }
        let max = textFiled.sb_maxLength
        let lang = textFiled.textInputMode?.primaryLanguage
        
        if let lan = lang, lan == "zh-Hans" {
            let range = textFiled.markedTextRange
            if range == nil {
                if text.count >= max {
                    textFiled.text = String(text.prefix(max))
                }
            }
        } else {
            textFiled.text = String(text.prefix(max))
        }
    }
}

// MARK: - UIView
open class BaseScene: UIView {
    /// Variables
    public var sectionTag: Int = 0
    
    deinit {
        print("scene 析构: class: \(type(of: self))")
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview == nil else {
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    public func stopAllRequest() {
        let this = NSStringFromClass(type(of: self))
        let tmp = this as NSString
        guard tmp.range(of: ".").location == NSNotFound else {
            let range = tmp.range(of: ".", options: .backwards)
            let nr = tmp.substring(with: NSMakeRange(range.location+1, this.count-range.location-range.length))
            SBHTTPRouter.shared.cancel(nr)
            return
        }
        SBHTTPRouter.shared.cancel(this)
    }
}

// MARK: - UINavigationBar
public class BaseNavigationBar: UINavigationBar {
    /// vars
    var offset:CGFloat {
        guard UIDevice.current.isX() else {
            return 0
        }
        return 30
    }
    /// lazy vars
    private lazy var shadowLine: BaseScene = {
        let s = BaseScene(frame: .zero)
        s.backgroundColor = AppColor.COLOR_EEEEEE
        return s
    }()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(shadowLine)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// re-layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        /// status bar height
        let statusBarHeight = AppSize.HEIGHT_STATUSBAR()
        let navigationBarHeight = AppSize.HEIGHT_NAVIGATIONBAR
        
        let allHeight = statusBarHeight+navigationBarHeight
        self.frame = CGRect(x: 0, y: 0, width: AppSize.WIDTH_SCREEN, height: allHeight)
        for v in self.subviews {
            v.layoutMargins = .zero
            let clsString = NSStringFromClass(type(of: v))
            if clsString.contains("Background") {
                v.frame = self.bounds
            } else if clsString.contains("ContentView") {
                var frame = v.frame;
                //frame.origin.x -= self.offset * 0.5;
                frame.origin.x = 0
                frame.origin.y = statusBarHeight;
                frame.size.height = allHeight - statusBarHeight;
                //frame.size.width += self.offset;
                frame.size.width = AppSize.WIDTH_SCREEN
                v.frame = frame;
            }
            
        }
        shadowLine.snp.makeConstraints { (m) in
            m.left.bottom.right.equalToSuperview()
            m.height.equalTo(AppSize.HEIGHT_LINE)
        }
    }
    public func shadowLine(_ color: UIColor) {
        shadowLine.backgroundColor = color
    }
//    public override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        guard self.superview != nil else {
//            return
//        }
//        if let lts = self.topItem?.leftBarButtonItems {
//            lts.forEach { (it) in
//                if let sp = it.customView as? BaseBarCustomScene {
//                    sp.position = .left
//                }
//            }
//        } else if let lts  = topItem?.rightBarButtonItems {
//            lts.forEach { (it) in
//                if let sp = it.customView as? BaseBarCustomScene {
//                    sp.position = .right
//                }
//            }
//        }
//    }
}
// MARK: - UIBarButtonItem custom view
public enum SBBarPosition {
    case left, right
}
public class BaseBarCustomScene: UIView {
    private var applied: Bool = false
    public var position: SBBarPosition = .left {
        didSet {
            debugPrint("did set postion, will update")
            layoutIfNeeded()
        }
    }
    public init(frame: CGRect, with posit: SBBarPosition) {
        super.init(frame: frame)
        self.position = posit
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard applied == false, #available(iOS 11, *) else {
            return
        }
        var tmp: UIView! = self
        while (tmp.isKind(of: UINavigationBar.self) == false), let tmps = tmp.superview {
            tmp = tmps
            if tmp.isKind(of: UIStackView.self), let tmpSuper = tmp.superview {
                if position == .left {
                    for cnst in tmpSuper.constraints {
                        guard let fit = cnst.firstItem, fit.isKind(of: UILayoutGuide.self), cnst.firstAttribute == .trailing else {
                            continue
                        }
                        tmpSuper.removeConstraint(cnst)
                    }
                    let ncnst = NSLayoutConstraint(item: tmp, attribute: .leading, relatedBy: .equal, toItem: tmpSuper, attribute: .leading, multiplier: 1.0, constant: 0)
                    tmpSuper.addConstraint(ncnst)
                    applied = true
                } else if position == .right {
                    for cnst in tmpSuper.constraints {
                        guard let fit = cnst.firstItem, fit.isKind(of: UILayoutGuide.self), cnst.firstAttribute == .leading else {
                            continue
                        }
                        tmpSuper.removeConstraint(cnst)
                    }
                    let ncnst = NSLayoutConstraint(item: tmp, attribute: .trailing, relatedBy: .equal, toItem: tmpSuper, attribute: .trailing, multiplier: 1.0, constant: 0)
                    tmpSuper.addConstraint(ncnst)
                    applied = true
                }
                break
            }
        }
    }
}

// MARK: - base loading
public class BaseLoading: BaseScene {
    /// lazy vars
    private lazy var acter: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        a.hidesWhenStopped = true
        return a
    }()
    public static let shared = BaseLoading(frame: .zero)
    private override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        addSubview(acter)
    }
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        acter.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
        }
    }
    public func showIn(_ view: UIView!) {
        isHidden = false
        if let father = view {
            acter.startAnimating()
            father.addSubview(self)
            self.snp.removeConstraints()
            self.snp.makeConstraints { (m) in
                m.edges.equalToSuperview()
            }
        }
    }
    public func hide(_ hide: Bool=true) {
        acter.stopAnimating()
        guard hide == true else {
            return
        }
        isHidden = true
        removeFromSuperview()
    }
}
