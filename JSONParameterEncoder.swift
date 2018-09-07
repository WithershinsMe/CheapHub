//
//  JSONParameterEncoder.swift
//  CheapHub
//
//  Created by GK on 2018/8/31.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Foundation

struct JSONParameterEncoder: ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkLayerError.encodingFailed
        }
    }
    
    
}
