//
//  NotificationToken.swift
//  CheapHub
//
//  Created by GK on 2018/8/20.
//  Copyright © 2018年 com.gk. All rights reserved.
//

import Foundation

final class NotificationToken: NSObject {
    
    let notificationCenter: NotificationCenter
    let token: Any
    
    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }
    
    deinit {
        notificationCenter.removeObserver(token)
    }
}

extension NotificationCenter {
    
    func observe(name: NSNotification.Name?, object obj: Any?,
                 queue: OperationQueue?, using block: @escaping (Notification) -> ())
        -> NotificationToken
    {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}
