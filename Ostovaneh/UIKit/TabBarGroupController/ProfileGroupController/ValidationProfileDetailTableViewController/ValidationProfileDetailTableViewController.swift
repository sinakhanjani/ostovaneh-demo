//
//  ValidationProfileDetailTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/23/1400 AP.
//

import UIKit
import RestfulAPI

class ValidationProfileDetailTableViewController: BaseTableViewController {

    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var enterProfileDetailButton: UIButton!
    @IBOutlet weak var titleProfileDetailLabel: UILabel!
    
    public var profileDetail: String?
    
    private let elapsedTimeInSecond = 60
    private var timer: TimerHelper?
    
    override func configUI() {
        super.configUI()
        navigationItem.largeTitleDisplayMode = .never
        // Passing Data
        
        if #available(iOS 15.0, *) {
            enterProfileDetailButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            enterProfileDetailButton.setNeedsUpdateConfiguration()
        }
        
        setupTimer()
    }
    
    private func setupTimer() {
        resendCodeButton.isEnabled = false
        resendCodeButton.setTitleColor(.lightText, for: .normal)
        resendCodeButton.setTitle("01:00", for: .normal)
        
        timer = nil
        timer = TimerHelper(elapsedTimeInSecond: elapsedTimeInSecond)
        timer?.start { [weak self] (secend,minute) in
            self?.resendCodeButton.setTitle("\(minute):\(secend)", for: .normal)
            if self?.resendCodeButton.title(for: .normal) == "00:00" {
                self?.resendCodeButton.setTitle("ارسال مجدد", for: .normal)
                self?.resendCodeButton.setTitleColor(.white, for: .normal)
                self?.resendCodeButton.isEnabled = true
            }
        }
    }
    
    private func otpCheckRequest() {
        struct Response: Codable {
            let data: String
        }
        
        if let profileInformation = data as? ProfileInformation, let field_to_update = profileInformation.field_to_update, let profileDetail = self.profileDetail {
            let network = RestfulAPI<EMPTYMODEL,Response>.init(path: "/v2/update_user")
                .with(auth: .user)
                .with(parameters: [field_to_update:profileDetail,
                                   "sms_token":codeTextField.text!.toEnNumber])
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
    
    
    @IBAction func resendCodeButtonTapped(_ sender: UIButton) {
        if let viewControllers = navigationController?.viewControllers {
            if let PreviousVC = viewControllers[viewControllers.count-2] as? EditProfileDetailTableViewController {
                setupTimer()
                PreviousVC.otpSendRequest(asResned: true)
            }
        }
    }
    
    @IBAction func enterProfileDetailButtonTapped(_ sender: UIButton) {
        guard codeTextField.text!.isEmpty == false else {
            showAlerInScreen(body: "لطفا ورودی اطلاعات را تکمیل نمایید")
            return
        }
        
        otpCheckRequest()
    }
}

