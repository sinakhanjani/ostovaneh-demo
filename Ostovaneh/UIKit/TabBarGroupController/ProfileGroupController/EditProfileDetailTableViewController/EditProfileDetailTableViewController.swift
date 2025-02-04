//
//  EnterPhoneNumberTableViewController.swift
//  Ostovaneh
//
//  Created by Hossein Hajimirza on 10/27/21.
//

import UIKit
import RestfulAPI

class EditProfileDetailTableViewController: BaseTableViewController {
    
    @IBOutlet weak var profileDetailTextField: UITextField!
    @IBOutlet weak var enterProfileDetailButton: UIButton!
    @IBOutlet weak var titleProfileDetailLabel: UILabel!
    
    private var profileInformation: ProfileInformation = .none
    private var currentHash: String = ""
    
    override func configUI() {
        super.configUI()
        navigationItem.largeTitleDisplayMode = .never
        // Passing Data
        if let data = data as? Dictionary<String,Any> {
            if let profileInformation = data["ProfileInformation"] as? ProfileInformation {
                profileDetailTextField.placeholder = profileInformation.palceHolder
                self.profileInformation = profileInformation
            }
            if let phoneNumber = data["phoneNumber"] as? String {
                currentHash = phoneNumber
            }
            if let email = data["email"] as? String {
                currentHash = email
            }
            if let username = data["username"] as? String {
                profileDetailTextField.text = username
            }
            if let password = data["password"] as? String {
                currentHash = password
            }
            currentHash = currentHash.toEnNumber
        }
        
        if #available(iOS 15.0, *) {
            enterProfileDetailButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            
            enterProfileDetailButton.setNeedsUpdateConfiguration()
        }
    }
    
    public func otpSendRequest(asResned: Bool = false) {
        struct Response: Codable {
            let data: String
        }
        // set information for Previous page
        if let field_to_update = profileInformation.field_to_update {
            
            switch profileInformation {
            case .mail:
                currentHash = profileDetailTextField.text!
            case .phoneNumber:
                currentHash = profileDetailTextField.text!
            case .username:
                break
            case .password:
                break
            case .none:
                break
            }
            currentHash = currentHash.toEnNumber
            
            let params = ["username":currentHash.toEnNumber,
                          "field_to_update":field_to_update.toEnNumber]
            let network = RestfulAPI<EMPTYMODEL,Response>.init(path: "/v2/otp_update_user")
                .with(auth: .user)
                .with(parameters: params)
                .with(method: .POST)

            handleRequestByUI(network, tappedButton: enterProfileDetailButton) { [weak self] result in
                guard let self = self else { return }
                if let result = result?.data {
                    if !asResned {
                        let warningVC = WarningContentViewController
                            .instantiate()
                            .alert(AlertContent(title: .none, subject: "", description: result))
                        
                        warningVC.yesButtonTappedHandler = { [weak self] in
                            guard let self = self else { return }
                            let vc = ValidationProfileDetailTableViewController
                                .instantiate()
                                .with(passing: self.profileInformation)
                            vc.profileDetail = self.profileDetailTextField.text?.toEnNumber
                            
                            self.show(vc,
                                       sender: nil)
                        }
                        
                        self.present(warningVC)
                    }
                }
            }
        }
        if case .username = profileInformation {
            let network = RestfulAPI<EMPTYMODEL,Response>.init(path: "/v2/update_user")
                .with(auth: .user)
                .with(parameters: ["name":profileDetailTextField.text!.toEnNumber])
                .with(method: .POST)
            
            handleRequestByUI(network, tappedButton: enterProfileDetailButton) { [weak self] result in
                guard let self = self else { return }
                if let result = result?.data {
                    let warningVC = WarningContentViewController
                        .instantiate()
                        .alert(AlertContent(title: .none, subject: "", description: result))
                    
                    warningVC.yesButtonTappedHandler = { [weak self] in
                        guard let self = self else { return }
                        self.navigationController?.popToRootViewController(animated: true)
                        NotificationCenter.default.post(name: .profileChangedNotification, object: nil)
                    }
                    
                    self.present(warningVC)
                }
            }
            
        }
    }
    
    @IBAction func enterProfileDetailButtonTapped(_ sender: UIButton) {
        guard profileDetailTextField.text!.isEmpty == false else {
            showAlerInScreen(body: "لطفا اطلاعات ورودی را تکمیل نمایید")
            return
        }
        
        otpSendRequest()
    }
}

enum ProfileInformation {
    case mail
    case phoneNumber
    case username
    case password
    case none
    
    var palceHolder: String {
        switch self {
        case .mail: return "ایمیل جدید خود را وارد کنید"
        case .phoneNumber: return "شماره تلفن همراه جدید خود را وارد کنید"
        case .username: return "نام‌ کاربری جدید خود را وارد کنید"
        case .password: return "کلمه رمز عبور جدید خود را وارد کنید"
        default: return ""
        }
    }
    
    var field_to_update: String? {
        switch self {
        case .mail:
            return "email"
        case .phoneNumber:
            return "mobile"
        case .username:
            return nil
        case .password:
            return "password"
        case .none:
            return nil
        }
    }
}
