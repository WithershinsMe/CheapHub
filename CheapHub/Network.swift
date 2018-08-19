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

enum APIEnvironment {
    case staging
    case qa
    case production
}

enum NetWorkError: Error {
    case NoError
    case BadNetwork
    case NeedRedirect
    case NeedAuthorization
    case DataMapError
    case responseError(String)
    case JSONParseError
    case DataParseError
   
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

        }
    }
}

protocol NetworkProtocol: AnyObject  {
    func networkActivityBegin()
    func networkActivityEnd()
}


fileprivate typealias NetworkJSON =  (_ result: Result<Dictionary<String, Any>, NetWorkError>) -> Void
fileprivate typealias NetworkCompletion<T> = (_ result: Result<T, NetWorkError>) -> Void

typealias NetworkResult<T> =  (_ result: Result<T, NetWorkError>) -> Void

private protocol Networkable {
    var provider: MoyaProvider<GitHub> { get }
    
   func getOauthAccessToken(_ code: String, _ state: String, completion: @escaping NetworkResult<String>)
   func getUserInfo(_ completion: @escaping NetworkResult<User>)
}

class Network: Networkable {
   
    static let manager = Network()
    fileprivate init() { }
    
    static let environment = APIEnvironment.staging
    
    weak var networkDelegate: NetworkProtocol?
    

    private lazy var networkPlugin = NetworkActivityPlugin.init { [weak self] (changeType, targetType) in
        print("\(targetType) + \(changeType)")
        
        switch (changeType) {
        case .began:
            self?.networkDelegate?.networkActivityBegin()
        case .ended:
            self?.networkDelegate?.networkActivityEnd()
        }
    }
    lazy var provider = MoyaProvider<GitHub>(plugins: [networkPlugin])

    func getUserInfo(_ completion: @escaping NetworkResult<User>) {
        guard let accessToken = UserDefaults.standard.string(forKey: UserDefaults.Keys.accessToken) else {
            completion(.failure(NetWorkError.NeedAuthorization))
            return
        }
        
        request(target: GitHub.user(accessToken: accessToken), User.self) { result in
            completion(result)
        }
    }
    
    //获取授权Token
    func getOauthAccessToken(_ code: String, _ state: String, completion: @escaping NetworkResult<String>) {
        requestJSON(target: GitHub.login(code: code, state: state)) { response in
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
    
    //直接转化为Module对象
    @discardableResult
    fileprivate func request<T: Decodable>(target: GitHub, _ type: T.Type,completion: @escaping NetworkCompletion<T>) -> Cancellable {
        return provider.request(target) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200 ... 299:
                    do {
                        let results = try JSONDecoder().decode(type, from: response.data)
                        completion(.success(results))
                    } catch {
                        completion(.failure(NetWorkError.DataMapError))
                    }
                case 300 ... 399:
                    completion(.failure(NetWorkError.NeedRedirect))
                case 400 ... 499:
                    completion(.failure(NetWorkError.NeedAuthorization))
                default:
                    completion(.failure(NetWorkError.responseError("请求出错了，请重试")))
                }
            case .failure:
                completion(.failure(NetWorkError.BadNetwork))
            }
        }
    }
    
    //解析为Dictionary<String, Any>
    @discardableResult
    fileprivate func requestJSON(target: GitHub,completion: @escaping NetworkJSON) -> Cancellable {
        return provider.request(target) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200 ... 299:
                    do {
                        let jsonData = try response.mapJSON()
                        if let json = jsonData as? Dictionary<String, Any> {
                            completion(.success(json))
                        }else {
                            completion(.failure(NetWorkError.DataParseError))
                        }
                    } catch {
                        completion(.failure(NetWorkError.JSONParseError))
                    }
                case 300 ... 399:
                    completion(.failure(NetWorkError.NeedRedirect))
                case 400 ... 499:
                    completion(.failure(NetWorkError.NeedAuthorization))
                default:
                    completion(.failure(NetWorkError.responseError("请求出错了，请重试")))
                }
            case .failure:
                completion(.failure(NetWorkError.BadNetwork))
            }
        }
    }
}


