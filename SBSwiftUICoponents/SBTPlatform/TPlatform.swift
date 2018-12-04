//
//  TPlatform.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/25.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import Alamofire
import SDWebImage
import SwiftyJSON
import SBComponents

// MARK: - Defines
public typealias TPShareCallback = (TPlatform)->Void
public let TPShareSceneHeight: CGFloat = 200

fileprivate let THIRD_WX_APPID = "wxfa827e3c1a13590e"
fileprivate let THIRD_WX_APPSECRET = "1c07b1856958233045ea2892f7c4f444"
fileprivate let THIRD_QQ_APPID = "1107800935"
fileprivate let THIRD_QQ_APPSECRET = "3C41AyNMnJcV4Ap3"
fileprivate let THIRD_Ali_APPID = "2017092208862735"        //ali-pay

/// 所有支持的schemes
fileprivate let SCHEME_APP = "sxtn"                         //自身
fileprivate let SCHEME_WECHAT = "wxfa827e3c1a13590e"        //微信
fileprivate let SCHEME_QQSHARE = "QQ4207B367"               //QQ分享
fileprivate let SCHEME_QQOAUTH = "tencent1107800935"        //QQ授权

/// 所有支持的第三方平台
public enum TPlatform {
    case none
    case qq
    case ali
    case wxSession
    case wxTimeline
    case wxFavorite
}

/// 支付方式
public enum PPlatform: Int, CaseIterable {
    case ali            =   1
    case wechat         =   2
    case applePay       =   3
    
    public func desc() -> String {
        switch self {
        case .ali:
            return "支付宝"
        case .wechat:
            return "微信支付"
        case .applePay:
            return "Apple Pay"
        }
    }
}

/// 课程激活方式
@objc public enum ActiveType: Int {
    case active     //主动激活
    case relative   //学习关联
    case granted    //被分享
}

/// 支付状态
public enum PayStatus: Int {
    case cancel = 6001
    case network = 6002
    case uncertain = 6004
    case failed = 4000
    case dealing = 8000
    case success = 9000
    case repeatReq = 5000
    case unknown
    
    func desc() -> String {
        switch self {
        case .cancel:
            return "您已取消！"///取消支付
        case .network:
            return "网络连接出错！"
        case .uncertain:
            return "支付结果未知，请查询订单列表中订单的支付状态！"
        case .failed:
            return "失败！"///订单支付失败
        case .dealing:
            return "正在处理中，支付结果未知，请查询订单列表中订单的支付状态！"
        case .success:
            return "成功！"///订单支付成功
        case .repeatReq:
            return "重复支付请求！"
        default:
            return "支付结果未知！"
        }
    }
}

// MARK: - 第三方平台组件API调用
public class TPOpen: NSObject {
    
    /// Callbacks
    public var callback: ErrorClosure?
    
    public var qqAuth: TencentOAuth?
    public static let shared = TPOpen()
    private override init() {}
    
    /// 注册IDs
    public func install() {
        WXApi.registerApp(THIRD_WX_APPID, enableMTA: false)
        qqAuth = TencentOAuth(appId: THIRD_QQ_APPID, andDelegate: TQQHandler.shared)
    }
    public func isInstalled(_ type: TPlatform) -> Bool {
        var ret: Bool = false
        switch type {
        case .qq:
            ret = QQApiInterface.isQQInstalled()
        case .wxSession, .wxFavorite, .wxTimeline:
            ret = WXApi.isWXAppInstalled()
        default:
            ret = false
        }
        return ret
    }
    /// 是否handle
    public func handle(_ uri: URL) -> Bool {
        guard let scheme = uri.scheme else {
            debugPrint("could not handle empty scheme:\(uri.absoluteString)")
            return false
        }
        /// universal-link/scheme-url
        if scheme.hasPrefix(SCHEME_APP) {
            TUniversalHandler.shared.handle(uri)
            return true
        }
        /// wx oauth/share
        if scheme.hasPrefix(SCHEME_WECHAT) {
            return WXApi.handleOpen(uri, delegate: TWXHandler.shared)
        }
        /// qq oauth
        if scheme.hasPrefix(SCHEME_QQOAUTH) {
            TencentOAuth.handleOpen(uri)
            return true
        }
        /// qq share
        if scheme.hasPrefix(SCHEME_QQSHARE) {
            return QQApiInterface.handleOpen(uri, delegate: TQQHandler.shared)
        }
        /// ali
        if let host = uri.host, host.hasSuffix("safepay") {
            TAliHandler.shared.handle(uri)
            return true
        }
        
        return true
    }
}

// MARK: - QQ SDK回调
class TQQHandler: NSObject, QQApiInterfaceDelegate, TencentSessionDelegate {
    /// TencentSessionDelegate
    func tencentDidLogin() {
        debugPrint("tencentDidLogin")
        guard let auth = TPOpen.shared.qqAuth, let token = auth.accessToken, let openid = auth.openId else {
            let e = BaseError("QQ登录异常！")
            TPOpen.shared.callback?(e)
            return
        }
        var p = [String: Any]()
        p["openId"] = openid
        p["accessToken"] = token
        var e = BaseError("")
        e.code = 0
        e.ext = p
        TPOpen.shared.callback?(e)
    }
    func tencentDidNotLogin(_ cancelled: Bool) {
        let e = BaseError( cancelled ? "取消登录！" : "登录失败！")
        TPOpen.shared.callback?(e)
    }
    func tencentDidNotNetWork() {
        let e = BaseError("网络不畅！")
        TPOpen.shared.callback?(e)
    }
    
    public static let shared = TQQHandler()
    private override init() {}
    public func onReq(_ req: QQBaseReq!) { }
    public func isOnlineResponse(_ response: [AnyHashable : Any]!) {  }
    
    public func onResp(_ resp: QQBaseResp!) {
        debugPrint("qq shre response")
        if let ret = resp as? SendMessageToQQResp {
            var desc: String! = "成功！"
            var code: Int = 0
            if ret.result != "0" {
                desc = "失败"
                code = -1
            }
            var e = BaseError(desc)
            e.code = code
            TPOpen.shared.callback?(e)
        }
    }
}

// MARK: - 微信SDK回调
class TWXHandler: NSObject, WXApiDelegate {
    public static let shared = TWXHandler()
    private override init() {}
    /// callback
    public func onResp(_ resp: BaseResp!) {
        debugPrint("wx response")
        
        /// whether share
        if let ret = resp as? SendAuthResp {
            /// 授权
            var p = [String: Any]()
            p["code"] = ret.code
            var e = convertResp2(ret)
            e.ext = p
            TPOpen.shared.callback?(e)
        } else if let ret = resp as? PayResp {
            /// 支付
            let e = convertResp2(ret)
            TPOpen.shared.callback?(e)
        } else if let ret = resp as? SendMessageToWXResp {
            ///分享
            let e = convertResp2(ret)
            TPOpen.shared.callback?(e)
        }
    }
    private func convertResp2(_ resp: BaseResp) -> BaseError {
        var status: PayStatus = .unknown
        switch resp.errCode {
        case 0:
            status = .success
        case -1:
            status = .failed
        case -2:
            status = .cancel
        default:
            status = .unknown
        }
        //callback
        var e = BaseError(status.desc())
        e.code = Int(resp.errCode)
        return e
    }
}

// MARK: - 阿里支付
class TAliHandler: NSObject {
    public static let shared = TAliHandler()
    private override init() {}
    
    /// handle
    public func handle(_ url: URL) {
        AlipaySDK.defaultService().processOrder(withPaymentResult: url) { (result) in
            if let ret: [String: Any] = result as? [String : Any] {
                let json = JSON(ret)
                let code = json["resultStatus"].intValue
                var status: PayStatus = .unknown
                if let stat = PayStatus(rawValue: code) {
                    status = stat
                }
                //                var orderNo: String?
                //                if status == .success {
                //                    let result = json["result"].stringValue
                //                    let retJson = JSON.init(parseJSON: result)
                //                    let appPay = retJson["alipay_trade_app_pay_response"]
                //                    let res = appPay["trade_no"]
                //                    orderNo = res.stringValue
                //                }
                
                //callback
                var e = BaseError(status.desc())
                if status == .success {
                    e.code = 0
                }
                TPOpen.shared.callback?(e)
            }
        }
    }
}

@objc protocol ActiveProtocol {
    @objc optional func active(_ map: [String: Any], with type: ActiveType)
}
// MARK: - 扫码/网页universal-link 打开app
class TUniversalHandler: NSObject {
    public static let shared = TUniversalHandler()
    private override init() {}
    
    public var delegate: ActiveProtocol?
    
    /// handle shceme-url
    public func handle(_ url: URL) {
        handleScan(url, completion: nil)
    }
    /// 扫码处理
    public func handleScan(_ link: URL, completion: ErrorClosure?=nil) {
        /// weak ref
        TPOpen.shared.callback = completion
        
        /// check scheme
        guard let scheme = link.scheme else {
            let e = BaseError("未知的应用scheme！")
            completion?(e)
            return
        }
        var uri: String = link.absoluteString
        let charactor = String(format: "url=%@", SCHEME_APP)
        if scheme.hasPrefix("http"), uri.contains(charactor) {
            let tmp_url = NSString(string: uri)
            let range = tmp_url.range(of: "url=")
            let len = tmp_url.length
            let start = range.location+range.length
            uri = tmp_url.substring(with: NSMakeRange(start, len-start))
        }
        var map = [String:Any]()
        guard let items = URLComponents(string: uri)?.queryItems else {
            debugPrint("empty items!")
            let err = BaseError("缺少query参数！")
            completion?(err)
            return
        }
        for q in items {
            map[q.name] = q.value
        }
        debugPrint("parser:\(map)")
        /// 激活类型
        var type: ActiveType = .active
        if uri.contains("curItemId") {
            type = .relative
        } else if uri.contains("share_course") {
            type = .granted
        }
        //active(map, with: type)
        delegate?.active?(map, with: type)
    }
    
//    /// 联网激活/关联 课程
//    private func active(_ map: [String: Any], with type: ActiveType) {
//        var path: SBHTTP!
//        var cid: Int = 0
//        var index: Int = 0
//        if type == .active {
//            path = SBHTTP.courseActive(map: map)
//        } else if type == .relative{
//            if let s = map["courseId"] as? String, let d = Int(s) {
//                cid = d
//            }
//            if let s = map["curItemId"] as? String, let d = Int(s) {
//                index = d
//            }
//            path = SBHTTP.courseRelative(cid: cid)
//        } else {
//            //            if let s = map["courseId"] as? String, let d = Int(s) {
//            //                cid = d
//            //            }
//            //            var uid: Int = 0
//            //            if let s = map["shareUserId"] as? String, let d = Int(s) {
//            //                uid = d
//            //            }
//            //            path = SBHTTP.courseActiveGrant(u: uid, c: cid)
//            path = SBHTTP.courseShared(map: map)
//        }
//
//        let excutor: NoneClosure = {[weak self] in
//            self?.active(map, with: type)
//        };
//        guard Kits.sessionValid() else {
//            var params = SBSceneRouteParameter()
//            params[Macros.APP_EXCUTE_BLOCK_DELAY] = excutor
//            let err = SBSceneRouter.route2(SBScenes.signin, params: params, space: nil, push: false)
//            Kits.handleError(err)
//            return;
//        }
//        SBHTTPRouter.shared.fetch(path) { [weak self](res, err, _) in
//            if let e = err {
//                //Kits.handleError(e, callback: excutor)
//                TPOpen.shared.callback?(e)
//                return
//            }
//            guard let json = res else {
//                let e = BaseError.init(Macros.EMPTY_DATA)
//                TPOpen.shared.callback?(e)
//                return
//            }
//            //parser
//            if type == .active {
//                cid = json["courseId"].intValue
//            }
//            self?.displayCourse(cid, index: index, with: type)
//        }
//    }
//    private func displayCourse(_ cid: Int, index: Int, with type: ActiveType) {
//        var scene: SBScenes!
//        var p = SBSceneRouteParameter()
//        if type == .relative {
//            p["lastId"] = index
//            p["courseId"] = cid
//            scene = .learnCourse
//        } else {
//            p["id"] = cid
//            scene = .courseInfo
//        }
//        let err = SBSceneRouter.route2(scene, params: p)
//        Kits.handleError(err)
//    }
}

// MARK: - 第三方授权
extension TPOpen {
    /// 三方登录
    public func oauth(_ platform: TPlatform, completion:@escaping ErrorClosure) {
        /// weak reference
        callback = completion
        
        switch platform {
        case .qq:
            debugPrint("qq oauth")
            let grants: [Any] = [kOPEN_PERMISSION_GET_INFO]
            qqAuth?.authorize(grants)
        case .wxSession, .wxTimeline, .wxFavorite:
            let req = SendAuthReq()
            req.scope = "snsapi_userinfo"
            req.state = "auth2_wx"
            WXApi.send(req)
        default:
            debugPrint("unkown platform to oauth!")
        }
    }
}

// MARK: - 第三方支付
extension TPOpen {
    public func pay(_ order: JSON?, payment way: PPlatform, completion:@escaping ErrorClosure) {
        /// weak refrerence
        callback = completion
        
        guard let json = order else {
            let err = BaseError("创建订单失败！")
            completion(err)
            return
        }
        
        switch way {
        case .ali:
            //let orderNum = json["orderNo"]
            let signature = json["sign"]
            debugPrint("ali order sign:\(signature.stringValue)")
            AlipaySDK.defaultService().payOrder(signature.stringValue, fromScheme: THIRD_Ali_APPID) { _ in /*called by web pay*/}
        case .wechat:
            let req = PayReq()
            req.partnerId = json["mch_id"].stringValue//商户ID
            req.prepayId = json["prepay_id"].stringValue
            req.package = "Sign=WXPay"
            req.nonceStr = json["nonce_str"].stringValue
            req.timeStamp = json["timeStamp"].uInt32Value
            req.sign = json["sign"].stringValue
            WXApi.send(req)
        default:
            debugPrint("unknown payment!")
        }
    }
}

// MARK: - 第三方分享
extension TPOpen {
    /// 分享网页链接
    public func shareLink(_ platform: [TPlatform], title: String, desciption desc: String, icon uri: String, hybrid link: String, profile: UIViewController, completion:@escaping ErrorClosure) {
        /// weak refrerence
        callback = completion
        
        let qqInstalled = isInstalled(.qq)
        let wxInstalled = isInstalled(.wxSession)
        if qqInstalled && wxInstalled {
            var p = SBParameter()
            p["platforms"] = platform
            let plater = TPShareProfile(p)
            let rooter = BaseNavigationProfile(rootViewController: plater)
            rooter.view.backgroundColor = ClearBgColor
            rooter.modalPresentationStyle = .overCurrentContext
            rooter.setNavigationBarHidden(true, animated: true)
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.type = CATransitionType(rawValue: "Reveal")
            animation.subtype = .fromTop
            animation.duration = Macros.APP_ANIMATE_INTERVAL
            UIApplication.shared.keyWindow?.layer.add(animation, forKey: nil)
            profile.present(rooter, animated: true, completion: nil)
            plater.platClosure = {[weak self](platform) in
                self?.shareLinkThrid(platform, title: title, desciption: desc, icon: uri, hybrid: link)
            }
            plater.cancelClosure = {[weak self] in
                self?.callback?(nil)
            }
            return
        }
        shareLinkSystem(title: title, desciption: desc, icon: uri, hybrid: link, profile: profile)
    }
    /// 分享链接（系统）
    private func shareLinkSystem(title: String, desciption desc: String, icon uri: String, hybrid link: String, profile: UIViewController) {
        var image: UIImage = UIImage()
        if let i = UIImage(named: "AppIcon") {
            image = i
        }
        
        let items:[Any] = [title, desc, image, link]
        let shreProfile = UIActivityViewController(activityItems: items, applicationActivities: nil)
        shreProfile.excludedActivityTypes = [.mail, .print, .airDrop, .message, .postToVimeo, .postToFlickr, .postToTwitter, .assignToContact, .saveToCameraRoll, .addToReadingList, .copyToPasteboard, .postToTencentWeibo]
        shreProfile.completionWithItemsHandler = { [weak self](type, completed, returnItems, error) in
            var err: BaseError?
            if completed == false, let e = error {
                err = BaseError(e.localizedDescription)
            }
            self?.callback?(err)
        }
        profile.present(shreProfile, animated: true, completion: nil)
    }
    /// 分享链接（sdk）
    private func shareLinkThrid(_ platform: TPlatform, title: String, desciption desc: String, icon uri: String, hybrid link: String) {
        BallLoading.show()
        SDWebImageDownloader.shared().downloadImage(with: URL(string: uri), options: [], progress: nil) { [weak self](image, data, err, finish) in
            BallLoading.hide()
            guard let icon = image else {
                let e = BaseError("分享图片数据错误！")
                self?.callback?(e)
                return
            }
            /// compress
            let compressed = icon.sb_compress(32768)
            //            guard let compressed = icon.sb_compress(32768) else {
            //                debugPrint("failed compress")
            //                let e = BaseError("failed compress")
            //                self?.callback?(e)
            //                return
            //            }
            /// share
            self?.realShareLink(platform, title: title, desciption: desc, icon: compressed, hybrid: link)
        }
    }
    private func realShareLink(_ platform: TPlatform, title: String, desciption desc: String, icon source: UIImage, hybrid link: String) {
        if platform == .wxSession || platform == .wxTimeline || platform == .wxFavorite {
            let msg = WXMediaMessage()
            msg.title = title
            msg.description = desc
            msg.setThumbImage(source)
            let webp = WXWebpageObject()
            webp.webpageUrl = link
            msg.mediaObject = webp
            let req = SendMessageToWXReq()
            req.bText = false
            req.scene = (platform == .wxSession ? 0 : (platform == .wxTimeline ? 1 : 2))//WXSceneSession
            req.message = msg
            WXApi.send(req)
        } else if platform == .qq {
            let data = source.jpegData(compressionQuality: 1)
            let obj = QQApiNewsObject.object(with: URL(string: link)!, title: title, description: desc, previewImageData: data)
            let req = SendMessageToQQReq(content: obj as? QQApiObject)
            let code = QQApiInterface.send(req)
            debugPrint("code:\(code.rawValue)")
        }
    }
    
    /// 分享纯图片
    public func shareImage(_ platform: TPlatform, icon source: UIImage, profile: UIViewController, completion:@escaping ErrorClosure) {
        
        let qqInstalled = isInstalled(.qq)
        let wxInstalled = isInstalled(.wxSession)
        if qqInstalled && wxInstalled {
            guard let data = source.jpegData(compressionQuality: 1) else {
                let e = BaseError("failed convert image to data binary!")
                completion(e)
                return
            }
            let preSize = CGSize(width: AppSize.HEIGHT_CELL, height: AppSize.HEIGHT_CELL)
            var thumbData: Data?
            if let previous = source.sb_resize(preSize), let p = previous.jpegData(compressionQuality: 1) {
                thumbData = p
            }
            realShareImage(platform, icon: data, thumb: thumbData)
            return
        }
        shareImageSystem(source, profile: profile)
    }
    private func shareImageSystem(_ icon: UIImage, profile: UIViewController) {
        let items:[Any] = [icon]
        let shreProfile = UIActivityViewController(activityItems: items, applicationActivities: nil)
        shreProfile.excludedActivityTypes = [.mail, .print, .airDrop, .message, .postToVimeo, .postToFlickr, .postToTwitter, .assignToContact, .saveToCameraRoll, .addToReadingList, .copyToPasteboard, .postToTencentWeibo]
        shreProfile.completionWithItemsHandler = { [weak self](type, completed, returnItems, error) in
            var err: BaseError?
            if completed == false, let e = error {
                err = BaseError(e.localizedDescription)
            }
            self?.callback?(err)
        }
        profile.present(shreProfile, animated: true, completion: nil)
    }
    private func realShareImage(_ platform: TPlatform, icon source: Data, thumb data: Data?) {
        if platform == .wxSession || platform == .wxTimeline || platform == .wxFavorite {
            let msg = WXMediaMessage()
            let obj = WXImageObject()
            obj.imageData = source
            msg.mediaObject = obj
            if let thumb = data {
                msg.thumbData = thumb
            }
            let req = SendMessageToWXReq()
            req.bText = false
            req.scene = (platform == .wxSession ? 0 : (platform == .wxTimeline ? 1 : 2))//WXSceneSession
            req.message = msg
            WXApi.send(req)
        } else if platform == .qq {
            let obj = QQApiImageObject(data: source, previewImageData: source, title: "", description: "")
            if let thumb = data {
                obj?.previewImageData = thumb
            }
            let req = SendMessageToQQReq(content: obj)
            let code = QQApiInterface.send(req)
            debugPrint("code:\(code.rawValue)")
        }
    }
    
    /// 分享多媒体-音乐
    public func shareMusic(_ title: String, desciption desc: String, icon uri: String, hybrid link: String, binary file: String, profile: UIViewController, completion:@escaping ErrorClosure) {
        /// weak refrerence
        callback = completion
        
        let qqInstalled = isInstalled(.qq)
        let wxInstalled = isInstalled(.wxSession)
        if qqInstalled && wxInstalled {
            let p = SBParameter()
            let plater = TPShareProfile(p)
            let rooter = BaseNavigationProfile(rootViewController: plater)
            rooter.view.backgroundColor = ClearBgColor
            rooter.modalPresentationStyle = .overCurrentContext
            rooter.setNavigationBarHidden(true, animated: true)
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.type = CATransitionType(rawValue: "Reveal")
            animation.subtype = .fromTop
            animation.duration = Macros.APP_ANIMATE_INTERVAL
            UIApplication.shared.keyWindow?.layer.add(animation, forKey: nil)
            profile.present(rooter, animated: true, completion: nil)
            plater.platClosure = {[weak self](platform) in
                self?.preShareMusic(platform, title: title, desciption: desc, icon: uri, hybrid: link, binary: file, profile: profile)
            }
            plater.cancelClosure = {[weak self] in
                self?.callback?(nil)
            }
            return
        }
        /// 音乐就当作链接分享
        shareLinkSystem(title: title, desciption: desc, icon: uri, hybrid: link, profile: profile)
    }
    /// 分享音乐（sdk）
    private func preShareMusic(_ platform: TPlatform, title: String, desciption desc: String, icon uri: String, hybrid link: String, binary file: String, profile: UIViewController) {
        /// qq分享音频
        guard platform != .qq else {
            let obj = QQApiAudioObject(url: URL(string: file)!, title: title, description: desc, previewImageURL: URL(string: uri)!, targetContentType: QQApiURLTargetTypeAudio)
            let req = SendMessageToQQReq(content: obj)
            let code = QQApiInterface.send(req)
            debugPrint("code:\(code.rawValue)")
            return
        }
        BallLoading.show()
        SDWebImageDownloader.shared().downloadImage(with: URL(string: uri), options: [], progress: nil) { [weak self](image, data, err, finish) in
            BallLoading.hide()
            guard let icon = image else {
                let e = BaseError("分享图片数据错误！")
                self?.callback?(e)
                return
            }
            /// compress
            let compressed = icon.sb_compress(32768)
            self?.realShareMusic(platform, title: title, desciption: desc, icon: compressed, hybrid: link, binary: file)
        }
    }
    private func realShareMusic(_ platform: TPlatform, title: String, desciption desc: String, icon source: UIImage, hybrid link: String, binary file: String) {
        if platform == .wxSession || platform == .wxTimeline || platform == .wxFavorite {
            let msg = WXMediaMessage()
            msg.title = title
            msg.description = desc
            msg.setThumbImage(source)
            let mscObj = WXMusicObject()
            mscObj.musicUrl = link
            mscObj.musicLowBandUrl = link
            mscObj.musicDataUrl = file
            mscObj.musicLowBandDataUrl = file
            msg.mediaObject = mscObj
            let req = SendMessageToWXReq()
            req.bText = false
            req.scene = (platform == .wxSession ? 0 : (platform == .wxTimeline ? 1 : 2))//WXSceneSession
            req.message = msg
            WXApi.send(req)
        }
    }
}
