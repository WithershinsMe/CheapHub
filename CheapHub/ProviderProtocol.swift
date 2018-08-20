//
//  ProviderProtocol.swift
//  CheapHub
//
//  Created by GK on 2018/8/20.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Moya
import Result

protocol ProviderProtocol {
    
    typealias NetworkCompletion<T> = (_ result: Result<T, NetWorkError>) -> Void
    typealias NetworkJSON<T> =  (_ result: Result<T, NetWorkError>) -> Void
    
    associatedtype TTargetType: TargetType

    var provider: MoyaProvider<TTargetType> { get set }
    
    @discardableResult
    func request<T: Decodable>(target: TTargetType, _ type: T.Type,callbackQueue: DispatchQueue?,progress: ProgressBlock? ,completion: @escaping NetworkCompletion<T>) -> Cancellable
    
    @discardableResult
    func requestJSON<T: Collection>(target: TTargetType,_ collection:T,callbackQueue: DispatchQueue? ,progress: ProgressBlock?  ,completion: @escaping NetworkJSON<T>) -> Cancellable
}

extension ProviderProtocol {
    
    //直接转化为Module对象
    @discardableResult
    func request<T: Decodable>(target: TTargetType, _ type: T.Type,callbackQueue: DispatchQueue? = .none,progress: ProgressBlock? = .none ,completion: @escaping NetworkCompletion<T>) -> Cancellable {
        
        return provider.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200 ... 299:
                    do {
                        let results = try JSONDecoder().decode(type, from: response.data)
                        completion(.success(results))
                    } catch {
                        if response.data.count == 0 {
                            completion(.failure(NetWorkError.SuccessNoData))
                        } else {
                            completion(.failure(NetWorkError.DataMapError))
                        }
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
        })
    }
    
    //解析为Dictionary<String, Any>
    @discardableResult
    func requestJSON<T: Collection>(target: TTargetType,_ collection:T,callbackQueue: DispatchQueue? = .none,progress: ProgressBlock? = .none ,completion: @escaping NetworkJSON<T>) -> Cancellable {
        
        return provider.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200 ... 299:
                
                    do {
                        let jsonData = try response.mapJSON()
                        if let json = jsonData as? T {
                            completion(.success(json))
                        } else {
                            completion(.failure(NetWorkError.DataParseError))
                        }
                    } catch {
                        if response.data.count == 0 {
                            completion(.failure(NetWorkError.SuccessNoData))
                        } else {
                            completion(.failure(NetWorkError.JSONParseError))
                        }
                    }
                case 300 ... 399:
                    completion(.failure(NetWorkError.NeedRedirect))
                case 400 ... 499:
                    completion(.failure(NetWorkError.NeedAuthorization))
                default:
                    completion(.failure(NetWorkError.responseError("请求出错了，请重试")))
                }
            case .failure(let error):
                let error = error as NSError
              
                switch error.code {
                case 400 ... 499:
                    completion(.failure(NetWorkError.BadNetwork))
                default:
                    completion(.failure(NetWorkError.responseError(error.localizedDescription)))
                }
                
            }
        })
        
    }
}
