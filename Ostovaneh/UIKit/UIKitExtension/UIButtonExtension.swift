//
//  UIButtonExtension.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/2/1400 AP.
//

import UIKit

extension UIButton {
    @available(iOS 15.0, *)
    func withFilledConfig() -> UIButton.Configuration {
        var filled = UIButton.Configuration.filled()
        var container = AttributeContainer()
        
        container.font = UIFont.iranSans(.medium, size: titleLabel!.font.pointSize)
        filled.buttonSize = .large
        filled.baseBackgroundColor = .OSTBlue
        filled.attributedTitle = AttributedString(title(for: .application)!, attributes: container)
        filled.titleAlignment = .trailing

        return filled
    }
}
