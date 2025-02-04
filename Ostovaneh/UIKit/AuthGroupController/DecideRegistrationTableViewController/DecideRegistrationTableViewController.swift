//
//  DecideRegistrationViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/27/1400 AP.
//

import UIKit

class DecideRegistrationTableViewController: BaseTableViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func configUI() {
        super.configUI()
        if #available(iOS 15.0, *) {
            loginButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            registerButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            
            loginButton.setNeedsUpdateConfiguration()
            registerButton.setNeedsUpdateConfiguration()
        }
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        show(LoginTableViewController
                .instantiate(), sender: nil)
    }
    
    @IBAction func registerButtonTapped(_ sender:UIButton) {
        show(RegisterTableViewController
                .instantiate(), sender: nil)
    }
}
