//
//  AuthAPI.swift
//  CheapHub
//
//  Created by GK on 2018/8/20.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Moya

enum  AuthConstant {
    static let clientID = "Iv1.d27989e19e3517f5"
    private static let clientSecret = "7340caed1ccfa8ab2c72c72390e594334b65d75e"
    static let redirectURL = "https://github.com/settings/apps/callback"
    fileprivate static let accessTokenDict = ["client_id":clientID,"client_secret":clientSecret,"redirect_uri":redirectURL]
}
enum AuthTarget {
    case login(code: String, state: String)
}
extension AuthTarget: TargetType {
    var baseURL: URL {
        return URL(string: "https://github.com")!
    }
    
    var path: String {
        return "/login/oauth/access_token"
    }
    
    var method: Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login(let code, let state):
            
            let parameters = AuthConstant.accessTokenDict.merging(["code":code,"state":state]) { (current, _) in current }
            return  .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Accept":"application/json"]
    }
    
    public var validationType: ValidationType {
        return .none
        
    }
}

class AuthAPI: ProviderProtocol {
    
    private init() { }
    static let manager = AuthAPI()
    
    lazy var provider = MoyaProvider<AuthTarget>(plugins: [networkPlugin])
    
    typealias TTargetType = AuthTarget
    
    private lazy var networkPlugin = NetworkActivityPlugin.init { [weak self] (changeType, targetType) in
       NotificationCenter.default.post(name: NSNotification.Name.NetworkActivityPluginChange, object: nil, userInfo: ["targetType" : targetType, "changeType":changeType])
    }
    
    //获取授权Token
    func getOauthAccessToken(_ code: String, _ state: String, completion: @escaping NetworkResult<String>) {
        requestJSON(target: TTargetType.login(code: code, state: state)) { response in
            switch response {
            case .success(let response):
                if let tokenString = response["access_token"] as? String {
                    completion(.success(tokenString))
                } else {
                    completion(.failure(NetWorkError.NeedAuthorization))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

