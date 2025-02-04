//
//  AlertContentModelData.swift
//  TEST
//
//  Created by Sina khanjani on 12/10/1399 AP.
//

import SwiftUI
import UIKit

final class AlertContentModelData: ObservableObject {
    
    @Published var alertContent: AlertContent
    
    internal init(alertContent: AlertContent) {
        self.alertContent = alertContent
    }
}
