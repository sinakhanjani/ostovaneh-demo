//
//  MainProfileTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/1/1400 AP.
//

import UIKit
import SafariServices
import RestfulAPI

class MainProfileTableViewController: BaseTableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var giftCodeButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var walletPriceLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var secondaryNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchInit { [weak self] in
            self?.updateInterface()
        }
    }
    
    override func configUI() {
        super.configUI()
        if #available(iOS 15.0, *) {
            giftCodeButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            logOutButton.configurationUpdateHandler = { button in
                button.configuration = button.withFilledConfig()
            }
            
            giftCodeButton.setNeedsUpdateConfiguration()
            logOutButton.setNeedsUpdateConfiguration()
        }
        updateInterface()
    }
    
    private func updateInterface() {
        if let userAttribute = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes {
            profileImageView.loadImage(from: userAttribute.imageUrl)
            if let credit = CustomerAuth.shared.loginResponseModel?.credit?.toPriceFormatter {
                if credit == "0" {
                    walletPriceLabel.text = "اعتبار صفر تومان"
                } else {
                    walletPriceLabel.text = "اعتبار \(credit) تومان"
                }
            }
            if let name = userAttribute.name {
                nameLabel.text = name
                secondaryNameLabel.text = name
            }
            if let refCode = userAttribute.ref_code {
                giftCodeButton.setTitle(refCode, for: .normal)
            }
            if let phone = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.mobile {
                phoneLabel.text = phone
            }
            if let email = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.email {
                emailLabel.text = email
            }
        }
    }
    
    private func fetchInit(completion: @escaping () -> Void) {
        let network = RestfulAPI<EMPTYMODEL,LoginResponseModel>.init(path: "/v2/init")
            .with(method: .POST)
            .with(auth: .user)
            .with(parameters: ["app_version":"1",
                               "app_sdk":"1",
                               "app_packagename":"hpen_ios"])
        
        handleRequestByUI(network,animated: true) { result in
            CustomerAuth.shared.loginResponseModel = result
            completion()
        }
    }
    
    private func uploadProfile(imageData: Data) {
        let network = RestfulAPI<File,Data>.init(path: "/v1/profile_image_upload")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: File(key: "image", data: imageData))
        
        handleRequestByUI(network, animated: true) { _ in
            //
        }
    }
    
    @IBAction func addProfilePhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let text = giftCodeButton.currentTitle!
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        present(vc)
    }
    
    @IBAction func websiteButtonTapped(_ sender: UIButton) {
        let ostovanehUrl = "https://ostovane.com".asURL!
        let ostovanehWebsiteSafariViewController = SFSafariViewController(url: ostovanehUrl)
        
        present(ostovanehWebsiteSafariViewController, animated: true, completion: nil )
    }
    
    @IBAction func instagramButtonTapped(_ sender: Any) {
        let instagramAppUrl = "instagram://user?username=ostovane.app".asURL!
        // check if the user has Instagram or not
        if UIApplication.shared.canOpenURL(instagramAppUrl) {
            UIApplication.shared.open(instagramAppUrl)
        } else {
            // redirect to Safari
            let instagramWebsiteUrl = "https://www.instagram.com/ostovane.app/".asURL!
            let ostovanehInstagramSafariViewController = SFSafariViewController(url: instagramWebsiteUrl)
            
            present(ostovanehInstagramSafariViewController)
        }
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        let alertVC = AlertContentViewController
            .instantiate()
            .alert(AlertContent(title: .none, subject: "خروج", description: "آیا میخواهید از حساب کاربری خارج شوید؟"))
            
        alertVC.yesButtonTappedHandler = { [weak self] in
            struct Logout: Codable { let status: String }
            let network = RestfulAPI<EMPTYMODEL,Logout>.init(path: "/v2/logout")
                .with(auth: .user)
            
            self?.handleRequestByUI(network, animated: true) { result in
                if let status = result?.status, status == "ok" {
                    // logout from user and others...
                    CustomerAuth.shared.logout()
                    UIApplication.set(root: StarterViewController
                                        .instantiate())
                }
            }
        }
        
        present(alertVC)
    }
}
// TableViewDelegate
extension MainProfileTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.item,indexPath.section) {
        case (0,1):
            show(WalletTableViewController
                    .instantiate(),
                 sender: nil)
        case (1,1):
            show(WishListTableViewController
                    .instantiate(),
                 sender: nil)
        case (let item,2):
            var dict = Dictionary<String,Any>()
            var profileInformation: ProfileInformation = .none
            switch item {
            case 0:
                if CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.email == nil {
                    showAlerInScreen(body: "برای تغییر شماره همراه میبایست پست الکترونیکی خود را ثبت کنید")
                    return
                }
                if let mobile = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.mobile {
                    dict = ["phoneNumber":mobile]
                }
                profileInformation = .phoneNumber
            case 1:
                if CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.mobile == nil {
                    showAlerInScreen(body: "برای تغییر پست الکترونیکی میبایست شماره همراه خود را ثبت کنید")
                    return
                }
                if let email = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.email {
                    dict = ["email": email]
                }
                profileInformation = .mail
            case 2:
                profileInformation = .username
//                dict = ["username":""]
            case 3:
                if let mobile = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.mobile {
                    dict = ["password":mobile]
                }
                if let email = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.attributes?.email {
                    dict = ["password":email]
                }
                profileInformation = .password
            default: break
            }
            dict.updateValue(profileInformation, forKey: "ProfileInformation")
            show(EditProfileDetailTableViewController
                    .instantiate()
                    .with(passing: dict),
                 sender: nil)
            // More section
        case(let item,4):
            switch item {
            case 0:
                let ostovanehUrl = "https://ostovane.com".asURL!
                let message = "سلام و عرض ادب، من استوانه را نصب کرده‌ام. استوانه یکی از جدید ترین سامانه‌ها در ایران است. شما با نصب رایگان استوانه میتوانید به هزاران کتاب مجازی، کتاب صوتی، مجلات، انیمیشن و فیلم‌های آموزشی به روز دست پیدا کنید و همچنین به حفظ محیط زیست در تولید کاغذ کمتر برای کتاب‌ها، کمک کنید. فقط کافیست روی لینک زیر کلیک کنید. \n"
                let vc = UIActivityViewController(activityItems: [message,ostovanehUrl], applicationActivities: nil)
                present(vc)
            case 1:
                show(ContactUsTableVIewController
                        .instantiate(), sender: nil)
            case 2:
                show(AboutUsTableViewController
                        .instantiate(), sender: nil)
            case 3:
                show(GuidePdfViewController
                        .instantiate(), sender: nil)
            case 4:
                show(FAQTableViewController
                        .instantiate(), sender: nil)
            default: break
            }
        default: break
        }
    }
}

extension MainProfileTableViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
            if let ImageData = image.jpegData(compressionQuality: 0.1) {
                uploadProfile(imageData: ImageData)
            }
            
            dismiss(animated: true)
        }
    }
}

