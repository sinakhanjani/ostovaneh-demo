//
//  UIApplicationExtension.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/30/1400 AP.
//

import UIKit
import RestfulAPI

extension UIApplication {
    static var appVersion: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String }
    static var appBuild: String { Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String }
    static var deviceID: String? { UIDevice.current.identifierForVendor?.uuidString }
    static var deviceType: String { UIDevice().model }
    
    static func set(root viewController: UIViewController) {
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}

