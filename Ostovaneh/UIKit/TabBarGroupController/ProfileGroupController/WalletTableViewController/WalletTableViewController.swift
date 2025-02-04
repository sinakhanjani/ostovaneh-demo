//
//  WalletTableViewController.swift
//  Ostovaneh
//
//  Created by Hossein Hajimirza on 10/27/21.
//

import UIKit
import RestfulAPI

class WalletTableViewController: BaseStoreTableViewController {
    
    @IBOutlet weak var iHaveGiftCodeButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var inputPriceTextField: UITextField!
    
    private var indexPath: IndexPath?
    private var priceItems = [10000,20000,30000,40000,50000]
    
    override func configUI() {
        super.configUI()
        navigationItem.largeTitleDisplayMode = .never
        inputPriceTextField.keyboardType = .asciiCapableNumberPad
        
        if #available(iOS 15.0, *) {
            iHaveGiftCodeButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            purchaseButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            
            iHaveGiftCodeButton.setNeedsUpdateConfiguration()
            purchaseButton.setNeedsUpdateConfiguration()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(paymnetChanged),
                                               name: .profileChangedNotification,
                                               object: nil)
    }
    
    override func updateUI() {
        super.updateUI()
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    @objc private func paymnetChanged() {
        UIApplication.set(root: StarterViewController
                            .instantiate())
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        if let creditUpPrice = Int(inputPriceTextField.text!), let jwt_token = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.jwt_token {
            if let url = URL(string: "\(Setting.baseURL.value)/v2/addfund?jwt_token=\(jwt_token)&price=\(creditUpPrice)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            return
        }
        
        showAlerInScreen(body: "لطفا مبلغ را وارد کنید")
    }
    
    @IBAction func iHaveGiftCodeButtonTapped(_ sender: UIButton) {
        if #available(iOS 15, *) {
            modalPresentationStyle = .pageSheet
            if let sheet = self.sheetPresentationController {
                sheet.detents =  [.medium(),.large()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            modalPresentationStyle = .automatic
        }
        
        present(EnterGiftCodeTableViewController
                    .instantiate())
    }
}

extension WalletTableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = (indexPath == self.indexPath && indexPath.section == 1) ? .checkmark:.none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.indexPath = indexPath
            tableView.reloadData()
            inputPriceTextField.text = "\(priceItems[indexPath.item])"
        }
    }
}
