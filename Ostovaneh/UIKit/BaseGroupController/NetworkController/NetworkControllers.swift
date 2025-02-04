//
//  NetworkViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/25/1400 AP.
//

import UIKit

class NetworkViewController: UIViewController, RestfulAPIDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorReachabilityChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanges(_:)), name: .reachabilityStatusChangedNotification, object: nil)
    }
    
    @objc func reachabilityStatusChanges(_ notification: Notification) {
        if let status = notification.userInfo?["Status"] as? ReachabilityStatus {
            switch status {
            case .offline:
                break
//                present(BadConnectionViewController.presentModally,
//                        animated: true)
            case .online(_):
                break
            default:
                break
            }
        }
    }
}

class NetworkTableViewController: UITableViewController, RestfulAPIDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorReachabilityChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanges(_:)), name: .reachabilityStatusChangedNotification, object: nil)
    }
    
    @objc func reachabilityStatusChanges(_ notification: Notification) {
        if let status = notification.userInfo?["Status"] as? ReachabilityStatus {
            switch status {
            case .offline:
                break
//                present(BadConnectionViewController.presentModally,
//                        animated: true)
            case .online(_):
                break
            default:
                break
            }
        }
    }
}

class NetworkCollecitonViewController: UICollectionViewController, RestfulAPIDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorReachabilityChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanges(_:)), name: .reachabilityStatusChangedNotification, object: nil)
    }
    
    @objc func reachabilityStatusChanges(_ notification: Notification) {
        if let status = notification.userInfo?["Status"] as? ReachabilityStatus {
            switch status {
            case .offline:
                break
//                present(BadConnectionViewController.presentModally,
//                        animated: true)
            case .online(_):
                break
            default:
                break
            }
        }
    }
}
