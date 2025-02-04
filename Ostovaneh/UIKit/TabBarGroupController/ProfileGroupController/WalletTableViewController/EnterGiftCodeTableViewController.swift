//
//  EnterGiftCodeTableViewController.swift
//  Ostovaneh
//
//  Created by Hossein Hajimirza on 10/30/21.
//

import UIKit
import RestfulAPI

protocol EnterGiftCodeTableViewControllerDelegate: AnyObject {
    func reedemCodeComplete(_ error: ErrorModel?)
}

protocol EnterGiftCodeTableViewControllerDataDelegate: AnyObject {
    func enterInput(data: String)
}

class EnterGiftCodeTableViewController: BaseTableViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: EnterGiftCodeTableViewControllerDelegate?
    weak var dataDelegate: EnterGiftCodeTableViewControllerDataDelegate?
    
    var productID: String?
    
    override func configUI() {
        super.configUI()
        if #available(iOS 15.0, *) {
            cancelButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            agreeButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            
            cancelButton.setNeedsUpdateConfiguration()
            agreeButton.setNeedsUpdateConfiguration()
        }
        
        if let identifier = data as? String, identifier == "fromBasket" {
            codeTextField.placeholder = "کد تخفیف را وارد کنید"
            titleLabel.text = "کد تخفیف خرید محصول"
        }
        
        if let identifier = data as? String, identifier == "fromGiftPhone" {
            codeTextField.placeholder = "شماره همراه شخص مورد نظر را وارد کنید"
            titleLabel.text = "هدیه محصول"
        }
        if let identifier = data as? String, identifier == "fromAddFolder" {
            codeTextField.placeholder = "نام پوشه را وارد کنید"
            titleLabel.text = "افزودن پوشه"
        }
    }
    
    private func discountRequest(code: String) {
        guard code.isEmpty == false else {
            showAlerInScreen(body: "لطفا کد تخفیف را وارد کنید")
            return
        }
        guard let orderID = CustomerAuth.shared.currentOrderModel?.data?.id else {
            showAlerInScreen(body: "حداقل یک محصول به سبد خرید اضافه کنید")
            return
        }
        let network = RestfulAPI<EMPTYMODEL,OrderResponseModel>.init(path: "/v1/submit_coupon")
            .with(auth: .user)
            .with(method: .POST)
            .with(parameters: ["coupon":code,
                               "order_id":orderID])
        
        handleRequestByUI(network, tappedButton: agreeButton) { [weak self] results in
            CustomerAuth.shared.currentOrderModel = results
            self?.dismiss(animated: true, completion: {
                self?.delegate?.reedemCodeComplete(results?.errors?[0])
            })
        }
    }
    
    private func giftRequest(code: String) {
        guard code.isEmpty == false else {
            showAlerInScreen(body: "لطفا کد هدیه را وارد کنید")
            return
        }
        let network = RestfulAPI<EMPTYMODEL,Data>.init(path: "/v2/submit_gift_code")
            .with(method: .POST)
            .with(auth: .user)
            .with(parameters: ["gift_code":codeTextField.text!])
        
        handleRequestByUI(network, tappedButton: agreeButton) { [weak self] result in
            if let data = result, let str = String(data: data, encoding: .utf8), let _ = Double(str) {
                NotificationCenter.default.post(name: .profileChangedNotification, object: nil)
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func giftPhoneRequest(phone: String) {
        guard let productID = productID, phone.isEmpty == false else {
            showAlerInScreen(body: "لطفا شماره همراه را وارد کنید")
            return
        }
        struct Model: Codable, Hashable {
            let data: IncludedTypeModel<UserAttributeModel,EMPTYHASHABLEMODEL>
        }
        let network = RestfulAPI<EMPTYMODEL,Model>.init(path: "/v1/send_gift")
            .with(method: .POST)
            .with(auth: .user)
            .with(parameters: ["mobile":phone,
                               "product_id":productID])
        
        handleRequestByUI(network, tappedButton: agreeButton) { [weak self] results in
            if let _ = results?.data.id {
                let alertContent = AlertContent(title: .none, subject: "", description: "محصول به کاربر مورد نظر هدیه داده شد. اکنون این محصول از لیست شما حذف و به لیست محصولات من کاربر مورد نظرتان اضافه شد.")
                let vc = WarningContentViewController
                    .instantiate()
                    .alert(alertContent)
                vc.yesButtonTappedHandler = {
                    UIApplication.set(root: StarterViewController
                                        .instantiate())
                }
                self?.present(vc)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func registerCodeButtonTapped(_ sender: UIButton) {
        if let identifier = data as? String, identifier == "fromBasket" {
            discountRequest(code: codeTextField.text!)
            return
        } else if let identifier = data as? String, identifier == "fromGiftPhone" {
            giftPhoneRequest(phone: codeTextField.text!)
            return
        } else if let identifier = data as? String, identifier == "fromAddFolder" {
            guard !codeTextField.text!.isEmpty else {
                showAlerInScreen(body: "نام پوشه را وارد کنید")
                return
            }
            dataDelegate?.enterInput(data: codeTextField.text!)
            self.dismiss(animated: true, completion: nil)
            return
        } else {
            giftRequest(code: codeTextField.text!)
            return
        }
    }
}
