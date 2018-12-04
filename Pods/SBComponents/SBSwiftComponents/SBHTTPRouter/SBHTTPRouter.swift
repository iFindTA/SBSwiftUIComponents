//
//  SBHTTPRouter.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/4.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

// MARK: - Variables
fileprivate let APP_TIMEOUT_INTERVAL  =   30.0
fileprivate let APP_PING_HOST = "www.baidu.com"
fileprivate let APP_CHECK_HOST = "www.qq.com"
public typealias SBResponse = (_ data: JSON?, _ error: BaseError?, _ page: JSON?) -> Void

// MARK: - Extension for Request
fileprivate extension URLSessionTask {
    private struct sb_associatedKeys {
        static var identifier_key = "identifier_key"
    }
    fileprivate var sb_identifier: String {
        get {
            guard let i = objc_getAssociatedObject(self, &sb_associatedKeys.identifier_key) as? String else {
                return ""
            }
            return i
        }
        set {
            objc_setAssociatedObject(self, &sb_associatedKeys.identifier_key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - 网络Router
public class SBHTTPRouter {
    /// variables
    //private var manager: NetworkReachabilityManager?
    public static let shared = SBHTTPRouter()
    private init() {}
    public func challengeNetworkPermission() {
        let url = URL(string: "https://baidu.com")
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: APP_TIMEOUT_INTERVAL)
        let session = URLSession.shared
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    /// inner action
    private func responseFilter(_ res: DataResponse<Any>) -> DataResponse<Any>? {
        let code = res.response?.statusCode
        guard code != SBHTTPRespCode.unAuthorization.rawValue, code != SBHTTPRespCode.forbidden.rawValue else {
            return nil
        }
        return res
    }
    /// parser for caller in stack
    private func parserStack(_ stack: String, with file: String) -> String {
        var patternScene: String = "\\$[A-z0-9a-z]+(Scene)"
        var patternProfile: String = "\\$[A-z0-9a-z]+(Profile)"
        if let bd = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
            patternScene = String(format: "%@+[A-Za-z0-9]+[Scene]", bd)
            patternProfile = String(format: "%@+[A-Za-z0-9]+[Profile]", bd)
        }
        var dest = matches(for: patternProfile, in: stack)
        var identifier: String = file
        if dest.count == 0 {
            dest = matches(for: patternScene, in: stack)
        }
        if dest.count > 0 {
            identifier = dest[0]
        }
        return identifier
    }
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            debugPrint("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    /// 返回401/403错误
    private func didCameForbiddenQuery() {
        //TODO:可以发送通知
    }
    /// network fetch event
    public func fetch(_ request: URLRequestConvertible, hud: Bool=true, hudString: String="", file: String=#file, completion:@escaping SBResponse) -> Void {
        let stacks = Thread.callStackSymbols
        var identifier = ((file as NSString).lastPathComponent as NSString).deletingPathExtension
        if stacks.count > 1 {
            identifier = parserStack(stacks[1], with: identifier)
        }
        if hud {
            Macros.executeInMain {
                BallLoading.show()
            }
        }
        let session = Alamofire.SessionManager.default
        let req = session.request(request).responseJSON { [weak self](response) in
            if hud {
                Macros.executeInMain {
                    BallLoading.hide()
                }
            }
            self?.handle(response, completion: completion)
        }
        req.task?.sb_identifier = identifier
    }
    private func handle(_ response: DataResponse<Any>, completion:@escaping SBResponse) -> Void {
        /// step1 filter response for authorization
        guard let newRes = responseFilter(response) else {
            var e = BaseError("授权已过期！")
            e.code = SBHTTPRespCode.forbidden.rawValue
            completion(nil, e, nil)
            didCameForbiddenQuery()
            return
        }
        
        /// step2 check error
        if let err = newRes.error {
            var e = BaseError(err.localizedDescription)
            e.code = (err as NSError).code
            completion(nil, e, nil)
            return
        }
        
        /// step3 check inner status
        guard newRes.result.isSuccess, let value = newRes.result.value, let json = JSON.init(rawValue: value) else {
            let e = BaseError("Oops，发生了系统错误！")
            completion(nil, e, nil)
            return
        }
        
        /// then, check status for this do-action
        var e: BaseError?
        if json["status"].intValue != 0 {
            e = BaseError(json["error"].stringValue)
        }
        /// finally, callback
        let page = json["page"]
        completion(json["data"], e, page)
    }
    public func cancelAll() {
        let session = Alamofire.SessionManager.default
        session.session.getAllTasks { (tasks) in
            tasks.forEach({ (t) in
                t.cancel()
            })
        }
    }
    public func cancel(_ file: String=#file) {
        let session = Alamofire.SessionManager.default
        session.session.getAllTasks { (tasks) in
            tasks.forEach({ (t) in
                if t.sb_identifier.contains(file) {
                    t.cancel()
                }
            })
        }
    }
}
