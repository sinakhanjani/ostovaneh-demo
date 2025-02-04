//
//  ResendPasswordViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/28/1400 AP.
//

import UIKit
import RestfulAPI

class ResendPasswordTableViewController: BaseTableViewController {
    
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
        func request(isEmail: Bool) {
            struct Resend1ResponseModel:Codable { let mobile: String? }
            struct Resend2ResponseModel:Codable { let data: String? }
            
            let networkStep1 = RestfulAPI<EMPTYMODEL,Resend1ResponseModel>.init(path: "/v1/forgotpass/step1")
                .with(method: .POST)
                .with(parameters: ["username":authTextField.text!.toEnNumber])
            
            handleRequestByUI(networkStep1, tappedButton: agreeButton) { [unowned self] result in
                let networkStep2 = RestfulAPI<EMPTYMODEL,Resend2ResponseModel>.init(path: "/v1/forgotpass/step2")
                    .with(method: .POST)
                    .with(parameters: ["username":authTextField.text!.toEnNumber,
                                       "key":isEmail ? "email":"mobile"])
                handleRequestByUI(networkStep2, tappedButton: agreeButton) { result2 in
                    if let result2 = result2?.data {
                        let alertContent = AlertContent(title: .none, subject: "", description: result2)
                        let vc = WarningContentViewController
                            .instantiate()
                            .alert(alertContent)
                        vc.yesButtonTappedHandler = { [weak self] in
                            self?.show(CodeVerificationTableViewController
                                        .instantiate()
                                        .with(passing: ["mobile":authTextField.text!.toEnNumber,"fromVC":"forgotpass"]),
                                       sender: nil)
                        }
                        
                        present(vc)
                    }
                }
            }
        }
        
        if authTextField.text!.toEnNumber.isValidEmail {
            // it's an email
            request(isEmail: true)
            return
        }
        if let no = authTextField.text, no.count >= 10, let _ = Int(no) {
            // it's an phone
            request(isEmail: false)
            return
        }
    }
}
