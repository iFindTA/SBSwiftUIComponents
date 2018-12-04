//
//  Share.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/14.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import Foundation

fileprivate let THIRD_ACC_UMENG = "5b1917b8f43e4816f000002c"
fileprivate let THIRD_URI_REDIRECT = "http://mobile.umeng.com/social"
fileprivate let THIRD_WX_APPID = "wxfa827e3c1a13590e"
fileprivate let THIRD_WX_APPSECRET = "1c07b1856958233045ea2892f7c4f444"
fileprivate let THIRD_QQ_APPID = "1107032734"
fileprivate let THIRD_QQ_APPSECRET = "jpxcrr67Et52dkVS"
fileprivate let THIRD_WB_APPID = "1107032734"
fileprivate let THIRD_WB_APPSECRET = "jpxcrr67Et52dkVS"

public struct Share {
    
    /// share
    public static func configureShares() {
        /*
        UMSocialGlobal.shareInstance().isUsingWaterMark = true
        UMSocialGlobal.shareInstance().isUsingHttpsWhenShareContent = false
        UMConfigure.initWithAppkey(THIRD_ACC_UMENG, channel: "App Store")
        //设置分享平台
        let redirectUri = THIRD_URI_REDIRECT
        UMSocialManager.default().setPlaform(.wechatSession, appKey: THIRD_WX_APPID, appSecret: THIRD_WX_APPSECRET, redirectURL: redirectUri)
        UMSocialManager.default().setPlaform(.wechatTimeLine, appKey: THIRD_WX_APPID, appSecret: THIRD_WX_APPSECRET, redirectURL: redirectUri)
        UMSocialManager.default().setPlaform(.QQ, appKey: THIRD_QQ_APPID, appSecret: THIRD_QQ_APPSECRET, redirectURL: redirectUri)
        UMSocialManager.default().setPlaform(.sina, appKey: THIRD_WB_APPID, appSecret: THIRD_WB_APPSECRET, redirectURL: redirectUri)
        */
       
    }
    
    /// payment
    public static func configurePayments() {
         //WXApi.registerApp(Macros.THIRD_WX_APPID)
    }
}

public extension Share {
    /*
    typealias KitsShareCallback = (Error?)->Void
    
    public static func share(_ title: String, desciption desc: String, icon: UIImage? = nil, iconUri: String, hybrid: String, profile: UIViewController, completion: @escaping KitsShareCallback) {
        
        let qqInstalled = UMSocialManager.default().isInstall(.QQ)
        let wxInstalled = UMSocialManager.default().isInstall(.wechatSession)
        if wxInstalled, qqInstalled {
            let platforms: [UMSocialPlatformType] = [.QQ, .wechatSession, .wechatTimeLine]
            UMSocialUIManager.setPreDefinePlatforms(platforms)
            UMSocialUIManager.showShareMenuViewInWindow { (type, info) in
                share2(type, title: title, desciption: desc, iconUri: iconUri, hybrid: hybrid, profile: profile, completion: completion)
            }
            return
        }
        //share from system
        var image: UIImage = UIImage()
        if let i = icon {
            image = i
        }
        let items:[Any] = [title, desc, image, hybrid]
        let shreProfile = UIActivityViewController(activityItems: items, applicationActivities: nil)
        shreProfile.excludedActivityTypes = [.mail, .print, .airDrop, .message, .postToVimeo, .postToFlickr, .postToTwitter, .assignToContact, .saveToCameraRoll, .addToReadingList, .copyToPasteboard, .postToTencentWeibo]
        shreProfile.completionWithItemsHandler = {(type, completed, returnItems, error) in
            var err: Error? = error
            if completed == false {
                err = BaseError.init("分享未完成")
            }
            completion(err)
        }
        profile.present(shreProfile, animated: true, completion: nil)
 
    }
    
    private static func share2(_ platform: UMSocialPlatformType, title: String, desciption desc: String, iconUri: String, hybrid: String, profile: UIViewController , completion: @escaping KitsShareCallback) {

        let bundle = Bundle.sb_displayName()
        let newTitle = "【\(bundle == nil ? "师享童年" : bundle!)】"
        //创建分享消息对象
        let messageObject = UMSocialMessageObject.init();
        //创建网页内容对象
        let shareObject = UMShareWebpageObject.init()
        shareObject.title = newTitle
        shareObject.descr = desc
        shareObject.thumbImage = iconUri
        shareObject.webpageUrl = hybrid
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject;
        //调用分享接口
        UMSocialManager.default().share(to: platform, messageObject: messageObject, currentViewController: profile) { (data, error) in
            guard error == nil else {
                completion(error)
                return
            }
            guard let res = data as? UMSocialShareResponse else {
                let err = BaseError.init("unknown response")
                completion(err)
                return
            }
            debugPrint("share result:\(res.message)")
            completion(nil)
        }
    }
 */
}
