//
//  UILabelExtension.swift
//  Master
//
//  Created by Sina khanjani on 10/9/1399 AP.
//

import UIKit

extension UILabel {
    ///Highlight a characters in words.
    func highlight(searchedText: String?, color: UIColor = .black) {
        guard let txtLabel = self.text, let searchedText = searchedText else {
            return
        }
        
        let attributeTxt = NSMutableAttributedString(string: txtLabel)
        let range: NSRange = attributeTxt.mutableString.range(of: searchedText, options: .caseInsensitive)
        attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        self.attributedText = attributeTxt
    }
    
    ///Add Line Spacing in a words.
    func addLineSpacing(spaceLine: CGFloat) {
        let attributedString =  NSMutableAttributedString(string: self.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spaceLine
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}
