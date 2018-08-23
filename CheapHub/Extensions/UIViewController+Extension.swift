//
//  UIViewController+Extension.swift
//  CheapHub
//
//  Created by GK on 2018/8/17.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String , alertHandle: ((UIAlertAction) -> Void)?) {
        let alertVC = UIAlertController(title: nil, message: title, preferredStyle: UIAlertControllerStyle.alert)
        if let alertHandle = alertHandle {
            let alertAction = UIAlertAction(title: "知道了", style: UIAlertActionStyle.cancel) { action in
                alertHandle(action)
            }
            alertVC.addAction(alertAction)
        }
        present(alertVC, animated: true, completion: nil)
    }
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChildViewController(child)
        view.addSubview(child.view)
        child.didMove(toParentViewController: self)
    }
    
    func remove() {
        guard parent != nil  else {
            return
        }
        
        willMove(toParentViewController: nil)
        removeFromParentViewController()
        view.removeFromSuperview()
    }
}
