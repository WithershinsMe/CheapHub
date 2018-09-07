//
//  EndPointType.swift
//  
//
//  Created by GK on 2018/8/31.
//

import Foundation

typealias HTTPHeaders = [String:String]

enum HttpMethod: String {
    case get      = "GET"
    case post     = "POST"
    case put      = "PUT"
    case patch    = "PATCH"
    case delete   = "DELETE"
}
enum HTTPTask {
    case request
    
    case requestParameters(bodyParameters: Parameters?, urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?,additionHeaders: HTTPHeaders?)
}
protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HttpMethod { get }
    var task: HTTPTask { get }
    var headers: HttpHeaders? { get }
}

