//
//  UITableViewCell+Extensions.swift
//  CheapHub
//
//  Created by GK on 2018/8/31.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit

protocol Reusable {}

//extension Reusable where Self: UITableViewCell {
//    static var reuseIdentifier: String {
//        return String(describing: self)
//    }
//}

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_ :T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReuseableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            return UITableViewCell() as! T
        }
        return cell
    }
}
