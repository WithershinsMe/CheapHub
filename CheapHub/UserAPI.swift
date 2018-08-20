//
//  UserAPI.swift
//  CheapHub
//
//  Created by GK on 2018/8/20.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Moya

enum UserTarget {
    case user(accessToken: String)
}
extension UserTarget: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        return "/user"
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
    
        case .user(let accessToken):
        return .requestParameters(parameters: ["access_token":accessToken], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Accept":"application/json"]
    }
}
class UserAPI: ProviderProtocol {
    
    private init() { }
    static let manager = UserAPI()

    lazy var provider = MoyaProvider<UserTarget>(plugins: [networkPlugin])
    
    typealias TTargetType = UserTarget

    private lazy var networkPlugin = NetworkActivityPlugin.init { (changeType, targetType) in
        NotificationCenter.default.post(name: NSNotification.Name.NetworkActivityPluginChange, object: nil, userInfo: ["targetType" : targetType, "changeType":changeType])
    }
    
    func getUserInfo(_ completion: @escaping NetworkResult<User>) {
        guard let accessToken = UserDefaults.standard.string(forKey: UserDefaults.Keys.accessToken) else {
            completion(.failure(NetWorkError.NeedAuthorization))
            return
        }
        
        request(target: UserTarget.user(accessToken: accessToken), User.self) { result in
            completion(result)
        }
    }
}
