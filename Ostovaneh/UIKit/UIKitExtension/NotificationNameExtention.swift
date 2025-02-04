//
//  NotificationNameExtention.swift
//  Master
//
//  Created by Sina khanjani on 11/26/1399 AP.
//

import Foundation

extension Notification.Name {
    static let reachabilityStatusChangedNotification =  NSNotification.Name(rawValue: "ReachabilityStatusChangedNotification")
    static let profileChangedNotification =  NSNotification.Name(rawValue: "gatewayChangedNotification")
    static let fileReviewTimeEnded =  NSNotification.Name(rawValue: "fileReviewTimeEnded")

}
