//
//  TestPaths.swift
//  SBSwiftComponents
//
//  Created by nanhu on 2018/9/19.
//  Copyright © 2018年 nanhu. All rights reserved.
//

import Alamofire
import SBComponents

/// Scene path
public enum TestPaths: SBScenePathable {
    case test
    case api
    case html
    case empty
    case share
    case snapkit
    case comment
    
    public func route() -> String {
        switch self {
        case .api:
            return "TestApiProfile"
        case .html:
            return "TestHtmlProfile"
        case .empty:
            return "TestEmptyProfile"
        case .share:
            return "TShare"
        case .snapkit:
            return "TestSnapkitProfile"
        case .comment:
            return "TestCommentProfile"
        default:
            return "SB404"
        }
    }
}

fileprivate let baseURI = "https://sxtn.landun.tech"
/// HTTP paths
public enum SBHTTP {
    case void
    case test
    case html(Int)
    
    var method: HTTPMethod {
        switch self {
        case .test:
            return .get
        default:
            return .get
        }
    }
    var path: String {
        switch self {
        case .test:
            return "app"
        case .html(let gid):
            return "prod/item/\(gid).json"
        default:
            return ""
        }
    }
    private func encoder() -> ParameterEncoding {
        let url:[HTTPMethod] = [.get, .head, .delete]
        if url.contains(method) {
            return URLEncoding.default
        }
        return JSONEncoding.default
    }
}
extension SBHTTP: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        let p: [String: Any] = {
            switch self {
            case .test:
                return [:]
            default:
                return [:]
            }
        }()
        
        let uri = try baseURI.asURL()
        var request = URLRequest(url: uri.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = 10
        
        let encoded = try encoder().encode(request, with: p)
        return encoded
    }
}
