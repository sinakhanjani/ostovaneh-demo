//
//  BadConnectionViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/25/1400 AP.
//

import UIKit

class BadConnectionViewController: UIViewController {
    static var presentModally: BadConnectionViewController {
        let vc = BadConnectionViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            let reachability = Reachability()
            if case .online(_) = reachability.connectionStatus() {
                self?.dismiss(animated: true)
            }
        })
    }
}
