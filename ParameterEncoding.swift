//
//  ParameterEncoding.swift
//  
//
//  Created by GK on 2018/8/31.
//

import Foundation

public typealias Parameters = [String:Any]
public enum NetworkLayerError: String, Error {
    case parametersNil = "Parameters were nil"
    case encodingFailed = "Parameter encoding failed"
    case missingURL = "URL is nil"
}
public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}
