//
//  ContactUsTableVIewController.swift
//  Ostovaneh
//
//  Created by Hossein Hajimirza on 10/27/21.
//

import UIKit
import MessageUI
import SafariServices

class ContactUsTableVIewController: BaseTableViewController {
    override func configUI() {
        super.configUI()
        navigationItem.largeTitleDisplayMode = .never
    }
}

extension ContactUsTableVIewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.item {
        case 1:
            if MFMailComposeViewController.canSendMail() {
                let vc = MFMailComposeViewController()
                
                vc.setSubject("Contact US")
                vc.setToRecipients(["info@ostovane.com"])
                vc.setMessageBody("", isHTML: false)
                
                present(UINavigationController(rootViewController: vc))
            } else {
                let mailURL = "https://google.com/gmail/about/".asURL!
                let vc = SFSafariViewController(url: mailURL)
                
                present(vc)
            }
        case 2:
            "02166569379".makeACall()
        default: break
        }
    }
}
