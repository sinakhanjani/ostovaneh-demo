//
//  AlertContent.swift
//  TEST
//
//  Created by Sina khanjani on 12/10/1399 AP.
//

import SwiftUI
import UIKit

final class AlertContent {
    internal enum AlertTitle: String, CaseIterable, Codable {
        case cancel = "انصراف"
        case none = "توجه"
        case delete = "حذف"
        case update = "بروز رسانی"
        
        var value: String { rawValue }
    }
    
    var title: AlertTitle
    var subject: String
    var description: String
        
    internal init(title: AlertTitle, subject: String, description: String) {
        self.title = title
        self.subject = subject
        self.description = description
    }
}
