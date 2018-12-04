//
//  Kits.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import SBToaster
import Foundation

fileprivate struct DateFmt {
    public let fmt: DateFormatter!
    static let shared = DateFmt()
    private init() {
        debugPrint("once for fmt!")
        fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
}

public struct Kits {
    
    /// snadbox path
    private static func sandBoxPath() -> String {
        return NSHomeDirectory()
    }
    public static func locatePath(_ type: SBUserPath, owner: String?=nil) -> String {
        var path: String = sandBoxPath() + "/Documents"
        switch type {
        case .file:
            path = path + "/files"
        case .audio:
            path = path + "/audios"
        case .image:
            path = path + "/images"
        case .video:
            path = path + "/videos"
        case .lyrics:
            path = path + "/lyrics"
        case .record:
            path = path + "/records"
        case .common:
            path = path + "/commons"
        default:
            debugPrint("uncatch user sandbox type\(type.rawValue)")
        }
        if let o = owner, o.count > 0, type == .record {
            path = path + "/" + o
        }
        /// create dir if not exists
        let f = FileManager.default
        if f.fileExists(atPath: path) == false {
            do {
                let uri = URL(fileURLWithPath: path)
                try f.createDirectory(at: uri, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("failed to create path:\(path)")
            }
        }
        return path
    }
    
    /// check inputs
    public static func checkAccount(_ input: String?) -> (Bool, String?) {
        guard let m = input, m.count > 0 else{
            makeToast("请输入手机号码！")
            return (false, nil)
        }
        let predicate = NSPredicate(format: "SELF MATCHES %@", Macros.REGULAR_MOBILE)
        guard predicate.evaluate(with: m) else {
            makeToast("请输入正确的手机号码！")
            return (false, nil)
        }
        return (true, m)
    }
    public static func checkPasswd(_ input: String?) -> (Bool, String?) {
        guard let p = input else {
            makeToast("请输入密码！")
            return (false, nil)
        }
        if p.count < Macros.LENGTH_PWD_MIN {
            makeToast("请输入\(Macros.LENGTH_PWD_MIN)~\(Macros.LENGTH_PWD_MAX)位密码！")
            return (false, nil)
        }
        return (true, p)
    }
    public static func checkVerifyCode(_ input: String?) -> (Bool, String?) {
        guard let p = input else {
            makeToast("请输入验证码！")
            return (false, nil)
        }
        if p.count < Macros.LENGTH_CODE_MIN {
            makeToast("请输入\(Macros.LENGTH_CODE_MIN)~\(Macros.LENGTH_CODE_MAX)位数字验证码！")
            return (false, nil)
        }
        return (true, p)
    }
    
    /// fetch page for scroller
    public static func fetchPage(_ scroller: UIScrollView) -> Int {
        let offsetX = scroller.contentOffset.x
        let width = floor(scroller.bounds.width)
        let p = floor(offsetX + width * 0.5) / width
        return Int(p)
    }
    
    /// MARK: UIBarButtonItems @attention: iOS11+失效
    public static func barSpacer(_ right: Bool=false) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        guard #available(iOS 11.0, *) else {
            item.width = right ? AppSize.WIDTH_MARGIN : -AppSize.WIDTH_MARGIN
            return item
        }
        item.width = right ? AppSize.WIDTH_MARGIN*1.5 : -AppSize.WIDTH_MARGIN
        return item
    }
    
    public static func defaultBackBarItem(_ target: Any?, action: Selector?) -> UIBarButtonItem {
        return Kits.defaultBackBarItem(target, action: action, color: AppColor.COLOR_NAVIGATOR_TINT)
    }
    
    public static func defaultBackBarItem(_ target: Any?, action: Selector?, color: UIColor?) -> UIBarButtonItem {
        return Kits.barWithUnicode("\u{e6e2}", title:nil, color: color, target: target, action: action)
    }
    
    public static func bar(_ code: String, title: String?, target: Any?, action: Selector?, right: Bool = false) -> UIBarButtonItem {
        return barWithUnicode(code, title: title, color: AppColor.COLOR_NAVIGATOR_TINT, target: target, action: action, right: right)
    }
    public static func bar(_ title: String, target: Any?, action: Selector?, right: Bool = false) -> UIBarButtonItem {
        let font = AppFont.pingFangSC(AppFont.SIZE_TITLE)
        let fontColor = AppColor.COLOR_NAVIGATOR_TINT
        let bar = self.bar(title, with: font, color: fontColor, target: target, action: action, right: right)
        return bar
    }
    private static func barWithUnicode(_ code: String, title: String?, color: UIColor?, target: Any?, action:Selector?, right: Bool = false) -> UIBarButtonItem {
        let font = AppFont.iconFont(AppFont.SIZE_TITLE * 1.5)
        let barTitle = code + String.available(title)
        let fontColor = ((color != nil) ?color!:UIColor.white)
        let bar = self.bar(barTitle, with: font, color: fontColor, target: target, action: action, right: right)
        return bar
    }
    private static func bar(_ title: String, with font: UIFont, color fontColor: UIColor, target: Any?, action: Selector?, right: Bool = false) -> UIBarButtonItem {
        let barSize = title.sb_size(AppSize.WIDTH_SCREEN, font: font)
        let btn = BaseButton(type: .custom)
        btn.titleLabel?.font = font
        btn.isExclusiveTouch = true
        btn.frame = CGRect(x: 0, y: 0, width: barSize.width+AppSize.SIZE_OFFSET, height: barSize.height+AppSize.SIZE_OFFSET)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(fontColor, for: .normal)
        btn.addTarget(target, action: action!, for: .touchUpInside)
        guard #available(iOS 11, *) else {
            return UIBarButtonItem(customView: btn)
        }
        let bar = UIBarButtonItem(customView: btn)
        bar.tintColor = fontColor
        return bar
    }
    
    /// Toaster
    public static func makeToast(_ info: String?) {
        let offset = ToastView.appearance().bottomOffsetPortrait
        if offset < AppSize.HEIGHT_SCREEN*0.5 {
            ToastView.appearance().bottomOffsetPortrait = AppSize.HEIGHT_SCREEN*0.5
        }
        DispatchQueue.main.async {
            Toast(text: info).show()
        }
    }
    public static func handleError(_ error: BaseError?, callback: VoidClosure?=nil) {
        guard let e = error else {
            ToastCenter.default.cancelAll()
            return
        }
        guard e.code != NSURLErrorCancelled else {
            debugPrint("user canceled!")
            return
        }
        if e.code == SBHTTPRespCode.forbidden.rawValue || e.code == SBHTTPRespCode.unAuthorization.rawValue {
            let alert = UIAlertController(title: nil, message: e.errDescription, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancel)
            let resign = UIAlertAction(title: "确定", style: .default) { (act) in
                Kits.route2SignIn(callback)
            }
            alert.addAction(resign)
            if let rooter = self.fetchRootProfile() {
                rooter.present(alert, animated: true, completion: nil)
            } else {
                makeToast("当前授权已过期，请重新登录！")
            }
            return
        }
        makeToast(e.errDescription)
    }
    
    /// re-signin
    private static func route2SignIn(_ excutor: VoidClosure?=nil) {
        /// 发通知实现 可优化：场景路由到授权
        let name = NSNotification.Name(Macros.APP_REQUEST_RESIGNIN)
        NotificationCenter.default.post(name: name, object: excutor)
    }
    private static func fetchRootProfile() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
}
