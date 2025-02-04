//
//  CellExtension.swift
//  Master
//
//  Created by Sina khanjani on 10/9/1399 AP.
//

import UIKit

extension UICollectionViewCell {
    //The @objc is added to silence the complier errors
    @objc class var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    //The @objc is added to silence the complier errors
    @objc class var identifier: String {
        return String(describing: self)
    }
}
