//
//  ObjectToDictionary.swift
//  CheapHub
//
//  Created by GK on 2018/9/6.
//  Copyright © 2018年 com.gk. All rights reserved.
//  Mirror 有着额外的开销，不宜在生产环境中使用，通常用于Debug来观察输出
//  实际开发中建议用Codable协议

import Foundation

protocol DictionaryValue {
    var value: Any { get }
}

extension Int : DictionaryValue { var value: Any { return self }}
extension Float : DictionaryValue { var value: Any { return self }}
extension String : DictionaryValue { var value: Any { return self }}
extension Bool : DictionaryValue { var value: Any { return self }}
extension Int8 : DictionaryValue { var value: Any { return self }}
extension Int16 : DictionaryValue { var value: Any { return self }}
extension Int32 : DictionaryValue { var value: Any { return self }}
extension Int64 : DictionaryValue { var value: Any { return self }}
extension Double : DictionaryValue { var value: Any { return self }}
extension Array: DictionaryValue where Element: DictionaryValue {
    var value: Any { return map{ $0.value } }
}
extension Dictionary: DictionaryValue where Value: DictionaryValue {
    var value: Any { return mapValues { $0.value } }
}
extension DictionaryValue {
    var value: Any {
        let mirror = Mirror(reflecting: self)
        var result  = [String: Any]()
        for child in mirror.children {
            if let key = child.label {
                if let value = child.value as? DictionaryValue {
                    result[key] = value.value
                }else {
                    result[key] = NSNull()
                }
            }
        }
        return result
    }
}
