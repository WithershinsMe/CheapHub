//
//  NetworkManager.swift
//  CheapHub
//
//  Created by GK on 2018/8/17.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Foundation
import Moya
import Result

public enum APIEnvironment {
    case staging
    case qa
    case production
}

public enum NetWorkError: Error {
    case NoError
    case BadNetwork
    case NeedRedirect
    case NeedAuthorization
    case DataMapError
    case responseError(String)
    case JSONParseError
    case DataParseError
    case SuccessNoData
    
    var rawValue: String {
        switch self {
        case .JSONParseError:
            return "数据解析错误"
        case .responseError(let error):
            if !error.isEmpty {
                return error
            }
            return "服务器出错了，请重试"
        case .DataParseError:
            return "返回的数据不符合约定的格式"
        case .BadNetwork:
            return "请检查网络连接"
        case .NeedRedirect:
            return "需要重定向"
        case .NeedAuthorization:
            return "需要授权"
        case .NoError:
            return ""
        case .DataMapError:
            return "请重试"
        case .SuccessNoData:
            return "请求成功但没有返回数据"
        }
    }
}

protocol NetworkProtocol: AnyObject  {
    func networkActivityBegin(_ targetType: TargetType)
    func networkActivityEnd(_ targetType: TargetType)
}


typealias NetworkResult<T> =  (_ result: Result<T, NetWorkError>) -> Void

class Network: ProviderProtocol {

    lazy var provider = MoyaProvider<GitHub>(plugins: [networkPlugin,NetworkLoggerPlugin(verbose: true)])

    typealias TTargetType = GitHub
    
    static let Manager = Network()
    
    static let User = UserAPI.manager
    static let Auth = AuthAPI.manager
    
    lazy var notificationToken: NotificationToken = NotificationCenter.default.observe(name: NSNotification.Name.NetworkActivityPluginChange, object: nil, queue: OperationQueue.main) { [weak self] (notification) in
        guard let `self` = self else {
            return
        }
        guard let info = notification.userInfo,let targetType = info["targetType"] as? TargetType, let changeType = info["changeType"] as? NetworkActivityChangeType else {
            return
        }
        
        switch (changeType) {
        case .began:
            self.networkDelegate?.networkActivityBegin(targetType)
        case .ended:
            self.networkDelegate?.networkActivityEnd(targetType)
        }
    }
    
    fileprivate init() {
        let _ = self.notificationToken
    }
    
    static let environment = APIEnvironment.staging
    
    weak var networkDelegate: NetworkProtocol?
    
    private lazy var networkPlugin = NetworkActivityPlugin.init { [weak self] (changeType, targetType) in
        print("\(targetType) + \(changeType)")
        
        switch (changeType) {
        case .began:
            self?.networkDelegate?.networkActivityBegin(targetType)
        case .ended:
            self?.networkDelegate?.networkActivityEnd(targetType)
        }
    }

    // upload
    func upload(_ data: Data, callbackQueue: DispatchQueue? = .none,progress: ProgressBlock? = .none, completion: @escaping NetworkResult<String>) {
        
        requestJSON(target: GitHub.upload(data: data), Dictionary<String, Any>()) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    // download
    func download(_ path: String, callbackQueue: DispatchQueue? = .none,progress: ProgressBlock? = .none, completion: @escaping NetworkResult<String>) {
        requestJSON(target: GitHub.download("logo_github.png"), Array<Any>()) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}



