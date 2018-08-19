//
//  GitHub.swift
//  CheapHub
//
//  Created by GK on 2018/8/15.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Moya
import Foundation

public enum GitHub {
    static let clientID = "Iv1.d27989e19e3517f5"
    private static let clientSecret = "7340caed1ccfa8ab2c72c72390e594334b65d75e"
    static let redirectURL = "https://github.com/settings/apps/callback"
    private static let accessTokenDict = ["client_id":clientID,"client_secret":clientSecret,"redirect_uri":redirectURL]
   
    case login(code: String, state: String)
    case user(accessToken: String)
}


extension GitHub: TargetType {
    public var baseURL: URL {
        switch self {
        case .login:
            return URL(string: "https://github.com")!
        default:
            return URL(string: "https://api.github.com")!
        }
    }

    public var path: String {
        switch self {
        case .login:
            return "/login/oauth/access_token"
        case .user:
            return "/user"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        switch self {
        case .login(let code, let state):
           
            let parameters = GitHub.accessTokenDict.merging(["code":code,"state":state]) { (current, _) in current }
            return  .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.default)
        case .user(let accessToken):
            return .requestParameters(parameters: ["access_token":accessToken], encoding: URLEncoding.default)
        }
    }

    public var headers: [String : String]? {
        return ["Accept":"application/json"]
    }

    public var validationType: ValidationType {
        return .successAndRedirectCodes
    }
}

