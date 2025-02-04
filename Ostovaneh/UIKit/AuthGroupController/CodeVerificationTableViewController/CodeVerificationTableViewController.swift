//
//  CodeVerificationViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/28/1400 AP.
//

import UIKit
import RestfulAPI

class CodeVerificationTableViewController: BaseTableViewController {
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    
    override func configUI() {
        super.configUI()
        if #available(iOS 15.0, *) {
            resendButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            resendButton.setNeedsUpdateConfiguration()
        }
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func resendButtonTapped(_ sender: Any) {
        guard let data = data as? [String:String], let mobile = data["mobile"], let fromVC = data["fromVC"], !mobile.isEmpty else {
            return
        }
        guard !codeTextField.text!.isEmpty else {
            showAlerInScreen(body: "لطفا کد احراز هویت را وارد کنید")
            return
        }
        
        if fromVC == "register" {
            let network = RestfulAPI<EMPTYMODEL,LoginResponseModel>.init(path: "/v2/users/verify")
                .with(method: .POST)
                .with(parameters: ["username":mobile.toEnNumber,
                                   "sms_token":codeTextField.text!.toEnNumber])
            
            handleRequestByUI(network, tappedButton: resendButton) { result in
                CustomerAuth.shared.loginResponseModel = result
                if let token = result?.token {
                    CustomerAuth.shared.registerUser(with: token)
                    UIApplication.set(root: StarterViewController
                                        .instantiate())
                }
            }
            return
        }
        if fromVC == "forgotpass" {
            struct Resend3ResponseModel:Codable { let allowed: Bool? }
            let network = RestfulAPI<EMPTYMODEL,Resend3ResponseModel>.init(path: "/v1/forgotpass/step3")
                .with(parameters: ["username":mobile.toEnNumber,
                                   "sms_token":codeTextField.text!.toEnNumber])
                .with(method: .POST)

            handleRequestByUI(network, tappedButton: resendButton) { [unowned self] result in
                if result?.allowed == true {
                    show(ChangePasswordTableViewController
                            .instantiate()
                            .with(passing: ["mobile":mobile.toEnNumber,
                                            "code": codeTextField.text!.toEnNumber]),
                         sender: nil)
                }
            }
            return
        }
    }
}
