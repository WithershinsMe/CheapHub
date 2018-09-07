//
//  NormalizedText.swift
//  
//
//  Created by GK on 2018/8/27.
//

import Foundation

struct NormalizedText {
    enum Error: Swift.Error {
        case empty
        case excessiveLength
        case unsupportedCharacters
    }
    
    static let maximumLength = 32
    
    var value: String
    
    init(_ string: String) throws {
        if string.isEmpty {
            throw Error.empty
        }
        
        guard let value = string.applyingTransform(.stripDiacritics,
                                                   reverse: false)?
            .uppercased(),
            value.canBeConverted(to: .ascii)
            else {
                throw Error.unsupportedCharacters
        }
        
        guard value.count < NormalizedText.maximumLength else {
            throw Error.excessiveLength
        }
        
        self.value = value
    }
}
