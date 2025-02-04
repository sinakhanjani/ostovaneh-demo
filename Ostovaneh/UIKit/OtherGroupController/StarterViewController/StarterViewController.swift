//
//  StarterViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/27/1400 AP.
//

import UIKit
import RestfulAPI

class StarterViewController: BaseViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch connetctionStatus {
        case .online(_):
            checkMinApplicationVersion()
        default:
            if let mainTabBarViewController = UITabBarController.instantiate(withId: "MainTabBarViewController") as? UITabBarController {
                if CustomerAuth.shared.isLogin {
                    UIApplication.set(root: mainTabBarViewController)
                } else {
                    if let nav = mainTabBarViewController.viewControllers?[0] as? UINavigationController {
                        nav.setViewControllers([DecideRegistrationTableViewController.instantiate()], animated: true)
                    }
                    if let nav = mainTabBarViewController.viewControllers?[4] as? UINavigationController {
                        nav.setViewControllers([DecideRegistrationTableViewController.instantiate()], animated: true)
                    }
                    // set window root to mainTabBar
                    UIApplication.set(root: mainTabBarViewController)
                }
            }
        }
    }
    
    private func checkMinApplicationVersion() {
        let network = RestfulAPI<EMPTYMODEL,Data>.init(path: "/v1/min-version")
            .with(method: .POST)
            .with(parameters: ["package_id":"19"])
        
        handleRequestByUI(network, animated: false) { [unowned self] result in
            if let result = result, let dataStr = String(data: result, encoding: .utf8) {
                if let appBuild = Int(UIApplication.appBuild), let serverVersion = Int(dataStr) {
                    if appBuild < serverVersion {
                        let alertContent = AlertContent(title: .none, subject: "آپدیت اجباری", description: "برای استفاده از اپلیکیشن لطفا به نسخه جدید به‌روز رسانی کنید")
                        let vc = WarningContentViewController
                            .instantiate()
                            .alert(alertContent)
                        
                        vc.yesButtonTappedHandler = {
                            let appstoreURL = "https://apps.apple.com/us/app/ostovanetodoapp/id1546346967".asURL!
                            // check if the user has Instagram or not
                            if UIApplication.shared.canOpenURL(appstoreURL) {
                                UIApplication.shared.open(appstoreURL)
                            }
                        }
                        self.present(vc)
                    } else {
                        luanchApplication()
                    }
                }
            }
        }
    }
    
    private func luanchApplication() {
        // set default store vc (index 2) for tabBar when presented
        if CustomerAuth.shared.isLogin {
            print("Bearer token:\n",CustomerAuth.shared.token!)
            let network = RestfulAPI<EMPTYMODEL,LoginResponseModel>.init(path: "/v2/init")
                .with(method: .POST)
                .with(auth: .user)
                .with(parameters: ["app_version":"1",
                                   "app_sdk":"1",
                                   "app_packagename":"hpen_ios"])
            
            handleRequestByUI(network) { result in
                CustomerAuth.shared.loginResponseModel = result
                if let mainTabBarViewController = UITabBarController.instantiate(withId: "MainTabBarViewController") as? UITabBarController {
                    mainTabBarViewController.selectedIndex = 2
                    UIApplication.set(root: mainTabBarViewController)
                }
            }
        } else {
            if let mainTabBarViewController = UITabBarController.instantiate(withId: "MainTabBarViewController") as? UITabBarController {
                if let nav = mainTabBarViewController.viewControllers?[0] as? UINavigationController {
                    nav.setViewControllers([DecideRegistrationTableViewController.instantiate()], animated: true)
                }
                if let nav = mainTabBarViewController.viewControllers?[4] as? UINavigationController {
                    nav.setViewControllers([DecideRegistrationTableViewController.instantiate()], animated: true)
                }
                mainTabBarViewController.selectedIndex = 2
                // set window root to mainTabBar
                UIApplication.set(root: mainTabBarViewController)
            }
        }
    }
}
