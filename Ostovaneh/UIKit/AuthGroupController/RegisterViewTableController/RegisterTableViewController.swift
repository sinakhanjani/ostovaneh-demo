//
//  RegisterViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/28/1400 AP.
//

import UIKit
import RestfulAPI
import GoogleSignIn

class RegisterTableViewController: BaseTableViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var fullyNameTextField: UITextField!
    @IBOutlet weak var referralCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func configUI() {
        super.configUI()
        if #available(iOS 15.0, *) {
            registerButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            registerButton.setNeedsUpdateConfiguration()
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let user = data as? GIDGoogleUser {
            let name = user.profile?.name ?? ""
            let family = user.profile?.familyName ?? ""
            fullyNameTextField.text = name + " " + family
            mobileTextField.text = user.profile?.email
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        guard !fullyNameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty else {
            showAlerInScreen(body: "فیلد نام کاربری یا رمز عبور خالی میباشد")
            return
        }
        
        var email = ""
        var phone = ""

        if mobileTextField.text!.toEnNumber.isValidEmail {
            email = mobileTextField.text!
        } else if mobileTextField.text!.toEnNumber.isValidPhone {
            phone = mobileTextField.text!
        } else {
            showAlerInScreen(body: "شماره موبایل یا ایمیل را به درستی وارد کنید")
            return
        }
        phone = phone.toEnNumber
        
        let body = RegisterBodyModel(name: fullyNameTextField.text!, password: passwordTextField.text!.toEnNumber, email: email, mobile: phone.toEnNumber, ref_by: !referralCodeTextField.text!.isEmpty ? referralCodeTextField.text!:"")
        let network = RestfulAPI<RegisterBodyModel,RegisterBodyModel>.init(path: "/v1/users")
            .with(body: body)
            .with(method: .POST)

        handleRequestByUI(network, tappedButton: registerButton) { [unowned self] result in
            if let _ = result {
                show(CodeVerificationTableViewController
                        .instantiate()
                        .with(passing: ["mobile":mobileTextField.text!.toEnNumber,"fromVC":"register"]),
                     sender: nil)
            }
        }
    }
}
