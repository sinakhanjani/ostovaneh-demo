//
//  WarningContentViewController.swift
//  TEST
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import SwiftUI
import UIKit

final class WarningContentViewController: UIHostingController<WarningContentView> {
        
    public var yesButtonTappedHandler: (() ->Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: WarningContentView())
        rootView.yesButton = yesButtonTapped

        view.backgroundColor = .clear
    }
    
    /// Add your custom alert message type as 'AlertContent'.
    public func alert(_ alertContent: AlertContent) -> Self {
        rootView.alertContentModelData = AlertContentModelData(alertContent: alertContent)
        
        return self
    }

    public func yesButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.yesButtonTappedHandler?()
        }
    }
}
