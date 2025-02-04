//
//  BaseDelegate.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/1/1400 AP.
//

import UIKit

protocol BaseControllerDelegate: UIViewController {
    var data: Any? { get set }
    func with(passing data: Any) -> Self
}

extension BaseControllerDelegate {
    func with(passing data: Any) -> Self {
        self.data = data
        
        return self
    }
}
