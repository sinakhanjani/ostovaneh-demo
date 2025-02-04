//
//  BundleExt.swift
//  Master
//
//  Created by Sina khanjani on 9/16/1399 AP.
//

import Foundation

extension Bundle {
    ///Sending the app version to API.
    ///Checking available updates.
    ///Including the app version into a support email.
    var appVersion: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    ///Main Application App Version.
    static var mainAppVersion: String? {
        Bundle.main.appVersion
    }
}
