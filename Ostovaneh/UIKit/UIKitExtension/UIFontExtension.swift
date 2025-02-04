//
//  FontExtension.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/28/1400 AP.
//

import UIKit

extension UIFont {
    enum IranSansWeight: String {
        case regular = "IRANSansX-Regular"
        case thin = "IRANSansX-Thin"
        case ultraThin = "IRANSansX-UltraLight"
        case light = "IRANSansX-Light"
        case medium = "IRANSansX-Medium"
        case demiBold = "IRANSansX-DemiBold"
        case bold = "IRANSansX-Bold"
        case extraBold = "IRANSansX-ExtraBold"
        case black = "IRANSansX-Black"
        
        var value: String { rawValue }
    }
    
    static func iranSans(_ weight: IranSansWeight, size: CGFloat) -> UIFont {
        UIFont(name: weight.value, size: size)!
    }
}
