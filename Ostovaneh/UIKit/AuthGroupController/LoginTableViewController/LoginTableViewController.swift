//
//  LoginViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/28/1400 AP.
//

import UIKit
import GoogleSignIn
import Firebase
import RestfulAPI

class LoginTableViewController: BaseTableViewController {
    
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var googleAuthController = GoogleAuthenticationController()
    
    override func configUI() {
        super.configUI()
        if #available(iOS 15.0, *) {
            loginButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            loginButton.setNeedsUpdateConfiguration()
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard !passwordTextField.text!.isEmpty && !mobileTextField.text!.isEmpty else {
            showAlerInScreen(body: "لطفا نام کاربری و رمز عبور را وارد کنید")
            return
        }
        
        let parameters = ["username":mobileTextField.text!.toEnNumber,
                          "password":passwordTextField.text!.toEnNumber,
                          "captchaText":"",
                          "captchaRand":""]
        let network = RestfulAPI<EMPTYMODEL,LoginResponseModel>.init(path: "/v2/login")
            .with(parameters: parameters)
            .with(method: .POST)
        
        handleRequestByUI(network, tappedButton: sender) { result in
            CustomerAuth.shared.loginResponseModel = result
            if let token = result?.token {
                CustomerAuth.shared.registerUser(with: token)
                UIApplication.set(root: StarterViewController
                                    .instantiate())
            }
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        show(ResendPasswordTableViewController
                .instantiate(), sender: nil)
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        show(RegisterTableViewController
                .instantiate(), sender: nil)
    }
    
    @IBAction func googleLoginButtonTapped(_ sender: Any) {
        googleAuthController.delegate = self
        googleAuthController.signIn(vc: self)
    }
}

extension LoginTableViewController: GoogleAuthenticationControllerDelegate {
    func signIn(user: GIDGoogleUser, credential: AuthCredential) {
        guard let idToken = user.authentication.idToken else {
            return
        }
        let network = RestfulAPI<EMPTYMODEL,LoginResponseModel>.init(path: "/v2/sing_in_with_google")
            .with(queries: ["token":idToken])
        
        handleRequestByUI(network) { [unowned self] result in
            CustomerAuth.shared.loginResponseModel = result
            if let token = result?.token {
                CustomerAuth.shared.registerUser(with: token)
                UIApplication.set(root: StarterViewController
                                    .instantiate())
            } else {
                show(RegisterTableViewController
                        .instantiate()
                        .with(passing: user), sender: nil)
            }
        }
    }
}
