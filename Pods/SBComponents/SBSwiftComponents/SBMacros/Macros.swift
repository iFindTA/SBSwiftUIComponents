//
//  Macros.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import UIKit
import Foundation

// MARK: - inline functions
public func RGBA(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
// MARK: - 以6的尺寸为准
public func adoptSize(_ size:CGFloat) -> CGFloat {
    return ceil(size*(AppSize.WIDTH_SCREEN/375.0))
}

/// 全局执行闭包
public typealias AnyClosure = ([String: Any])->Void
public typealias TagClosure = (Int)->Void
public typealias VoidClosure = ()->Void
public typealias BoolClosure = (Bool)->Void
public typealias StringClosure = (String)->Void
public typealias ErrorClosure = (BaseError?)->Void
public typealias SBParameter = [String: Any]

// MARK: - Macros Defines
public struct Macros {
    /// 状态栏是否全局控制 View controller-based status bar appearance = NO
    public static let APP_STATUSBAR_GLOBAL_EFFECT   =   true;
    public static let APP_ANIMATE_INTERVAL = 0.25
    public static let APP_HUD_INTERVAL = 1.5
    public static let APP_COUNT_DOWN_MAX: Int = 59
    public static let APP_APNS_TOKEN = "APP_APNS_TOKEN"
    public static let APP_USER_DID_INITIATIVE_LOGOUT = "APP_USER_DID_INITIATIVE_LOGOUT"
    public static let APP_EXCUTE_BLOCK_DELAY = "APP_EXCUTE_BLOCK_AFTER_DELAY"
    public static let APP_EXCUTE_BLOCK_FORWARD = "APP_EXCUTE_BLOCK_FORWARD"
    public static let APP_WHETHER_SHOW_VISITOR_WHEN_SIGNIN = "APP_WHETHER_SHOW_VISITOR_WHEN_SIGNIN"
    public static let APP_WHETHER_SHOULDGOBACK_WHEN_SIGNIN = "APP_WHETHER_SHOULDGOBACK_WHEN_SIGNIN"
    public static let APP_REQUEST_RESIGNIN = "APP_REQUEST_RESIGNIN" //用户授权过期
    
    /// notifications
    public static let APP_USER_DID_KICKOUT = "APP_USER_DID_KICKOUT" //用户被蹬出
    /// 音频服务即将被独占通知
    public static let APP_AUDIO_WILL_EXCLUSIVE = "APP_AUDIO_WILL_EXCLUSIVE"
    /// 音频已经开始播放
    public static let APP_AUDIO_DID_START = "APP_AUDIO_DID_START"
    /// 音频已经停止播放
    public static let APP_AUDIO_DID_END = "APP_AUDIO_DID_END"
    
    /// 正则表达式
    public static let REGULAR_MOBILE = "^1+[34578]+\\d{9}"
    
    /// 输入长度限制
    public static let LENGTH_PWD_MIN: Int = 6
    public static let LENGTH_PWD_MAX: Int = 12
    public static let LENGTH_CODE_MIN: Int = 4
    public static let LENGTH_CODE_MAX: Int = 8
    public static let LENGTH_MOBILE_CN: Int = 11
    
    public static let PAGING_SIZE: Int = 20//默认分页大小
    
    /// 空页面提示
    public static let EMPTY_PLACEHOLDER_ICONFONT = "\u{e673}"
    public static let EMPTY_TITLE = "Oops!"
    public static let EMPTY_DATA = "这里什么都木有~"
    public static let EMPTY_NETWORK = "您貌似断开了互联网链接，请检查网络稍后重试！"
    
    /// Cordova
    public static let CORDOVA_KEY_STARTPAGE = "CORDOVA_KEY_STARTPAGE"
    
    /// Methods
    public static func executeInMain(_ closure:@escaping VoidClosure) {
        if Thread.current.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}

// MARK: - app字体
public struct AppFont {
    //字体
    public static let PF_SC = "PingFangSC-Regular"
    public static let PF_BOLD = "PingFangSC-SemiBold"
    public static let PF_MEDIUM = "PingFangSC-Medium"
    public static let ICONFONT = "iconfont"
    //大小
    public static let SIZE_TITLE: CGFloat = 15.0
    public static let SIZE_LARGE_TITLE: CGFloat = 18.0
    public static let SIZE_SUB_TITLE: CGFloat = 13.0
    //字体
    public static func pingFangSC(_ size: CGFloat) -> UIFont {
        return UIFont(name: PF_SC, size: size)!
    }
    public static func pingFangMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: PF_MEDIUM, size: size)!
    }
    public static func pingFangBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: PF_BOLD, size: size)!
    }
    //iconfont
    public static func iconFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "iconfont", size: size)!
    }
}

// MARK: - app常量尺寸
public struct AppSize {
    //屏幕
    public static let WIDTH_SCREEN: CGFloat = UIScreen.main.bounds.size.width
    public static let HEIGHT_SCREEN: CGFloat = UIScreen.main.bounds.size.height
    public static let SCALE_SCREEN: CGFloat = UIScreen.main.scale
    
    //圆角角度
    public static let SIZE_OFFSET: CGFloat = 2.0
    public static let RADIUS_NORMAL: CGFloat = 4.0
    
    //宽度
    public static let WIDTH_DIS: CGFloat = 5
    public static let WIDTH_MARGIN: CGFloat = 10
    public static let WIDTH_BOUNDARY: CGFloat = 20
    //高度
    public static let HEIGHT_LINE: CGFloat = 1.0
    public static let HEIGHT_CELL: CGFloat = 50
    public static let SCALE_HUD: CGFloat = 0.85
    public static let SCALE_AREA_PICKER: CGFloat = 0.65
    public static func HEIGHT_TABBAR() -> CGFloat {
        guard UIDevice.current.isX() else {
            return 50
        }
        return 83
    }
    public static let HEIGHT_SUBBAR: CGFloat = 40
    public static let HEIGHT_ICON: CGFloat = 30
    public static let HEIGHT_NAVIGATIONBAR: CGFloat = 44
    public static func HEIGHT_STATUSBAR() -> CGFloat {
        guard UIDevice.current.isX() else {
            return 20
        }
        return 44
    }
    public static func HEIGHT_INVALID_BOTTOM() -> CGFloat {
        guard UIDevice.current.isX() else {
            return 0
        }
        return 33
    }
    public static func HEIGHT_AVAILABLE_EXCLUDEBAR() -> CGFloat {
        return HEIGHT_SCREEN - HEIGHT_STATUSBAR() - HEIGHT_NAVIGATIONBAR - HEIGHT_INVALID_BOTTOM()
    }
    //video
    public static let SCALE_VIDEO: CGFloat = 16/9.0
    public static func HEIGHT_VIDEO() -> CGFloat {
        return ceil(WIDTH_SCREEN / SCALE_VIDEO)
    }
    
    //rotate
    public static func WIDTH_SCREEN_FIXED() -> CGFloat {
        return min(HEIGHT_SCREEN, WIDTH_SCREEN)
    }
    public static func HEIGHT_SCREEN_FIXED() -> CGFloat {
        return max(HEIGHT_SCREEN, WIDTH_SCREEN)
    }
}

// MARK: - app颜色
public struct AppColor {
    public static let COLOR_LINE = RGBA(r: 221, g: 221, b: 221, a: 1)//0xdddddd
    public static let COLOR_LINE_GRAY = RGBA(r: 238, g: 238, b: 238, a: 1)//0xeeeeee
    public static let COLOR_THEME = RGBA(r: 16, g: 142, b: 233, a: 1)
    public static let COLOR_TITLE = RGBA(r: 51, g: 51, b: 51, a: 1)//0x333333
    public static let COLOR_TITLE_GRAY = RGBA(r: 102, g: 102, b: 102, a: 1)//0x666666
    public static let COLOR_TITLE_LIGHTGRAY = RGBA(r: 153, g: 153, b: 153, a: 1)//0x999999
    public static let COLOR_NAVIGATOR_TINT = RGBA(r: 76, g: 75, b: 85, a: 1)
    public static let COLOR_CCCCCC = RGBA(r: 204, g: 204, b: 204, a: 1)//0xCCCCCC
    public static let COLOR_DDDDDD = RGBA(r: 221, g: 221, b: 221, a: 1)//0xDDDDDD
    public static let COLOR_EEEEEE = RGBA(r: 238, g: 238, b: 238, a: 1)//0xEEEEEE
    public static let COLOR_BG_GRAY = RGBA(r: 248, g: 248, b: 248, a: 1)//0xF8F8F8
}

// MARK: - 网络定义
public enum SBHTTPRespCode: Int {
    case unAuthorization = 401  //未授权
    case forbidden = 403        //禁止访问 没有权限
}

// MARK: - 用户沙盒类型
public enum SBUserPath: Int {
    case root
    case file
    case image
    case video
    case audio
    case lyrics
    case record
    case common
}

// MARK: - app显示类型
public enum SceneType: Int {
    case none
    case main
    case oauth
    case visitor
}
