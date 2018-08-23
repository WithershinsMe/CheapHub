//
//  BottomSheetBackgroundView.swift
//  CheapHub
//
//  Created by GK on 2018/8/23.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit

private let borderWidth: CGFloat = 1
private let cornerRadius: CGFloat = 12

class BottomSheetBackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = cornerRadius
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = borderWidth
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.bounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width + borderWidth * 2, height: bounds.size.height))
    }
}
