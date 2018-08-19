//
//  Image+Extension.swift
//  CheapHub
//
//  Created by GK on 2018/8/16.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit

extension CIImage {
    func toUIImage() -> UIImage? {
        let context: CIContext = CIContext.init(options: nil)
        
        if let cgImage: CGImage = context.createCGImage(self, from: self.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
