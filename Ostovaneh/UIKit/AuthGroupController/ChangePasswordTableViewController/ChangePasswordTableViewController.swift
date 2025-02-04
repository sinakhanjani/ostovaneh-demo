//
//  ChangePasswordTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/15/1400 AP.
//

import UIKit
import RestfulAPI

class ChangePasswordTableViewController: BaseTableViewController {
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var authTextField: UITextField!
    
    override func configUI() {
        super.configUI()
        if #available(iOS 15.0, *) {
            agreeButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            agreeButton.setNeedsUpdateConfiguration()
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func agreeButtonTapped(_ sender: Any) {
        guard authTextField.text!.count >= 8 else {
            showAlerInScreen(body: "رمز عبور میبایست حداقل ۸ کاراکتر باشد")
            return
        }
        
        if let data = data as? [String:String], let mobile = data["mobile"], let code = data["code"] {
            let network = RestfulAPI<EMPTYMODEL,LoginResponseModel>.init(path: "/v2/forgotpass/step4")
                .with(parameters: ["username":mobile.toEnNumber,
                                   "password":authTextField.text!.toEnNumber,
                                   "sms_token":code.toEnNumber])
                .with(method: .POST)
            
            handleRequestByUI(network, tappedButton: agreeButton) { result in
                CustomerAuth.shared.loginResponseModel = result
                if let token = result?.token {
                    CustomerAuth.shared.registerUser(with: token)
                    UIApplication.set(root: StarterViewController
                                        .instantiate())
                }
            }
        }
    }
}
