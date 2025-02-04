//
//  NetworkAPIDelegate.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/25/1400 AP.
//

import UIKit
import RestfulAPI

private let reachability = Reachability()

protocol RestfulAPIDelegate: UIViewController {
    var connetctionStatus: ReachabilityStatus { get }
    
    func handleRequestByUI<S,R>(_ network: RestfulAPI<S,R>, animated: Bool, tappedButton: UIButton?, completion: @escaping (R?) -> Void, error: ((Error)->Void)?)
    func monitorReachabilityChanged()
}

extension RestfulAPIDelegate {
    public var connetctionStatus: ReachabilityStatus {
        let status = reachability.connectionStatus()
        
        return status
    }
    
    private func disableAnimate(animated: Bool, tappedButton: UIButton?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let tappedButton = tappedButton {
                if #available(iOS 15.0, *) {
                    tappedButton.configurationUpdateHandler = { button in
                        var config = button.withFilledConfig()
                        config.showsActivityIndicator = false
                        button.configuration = config
                    }
                    tappedButton.setNeedsUpdateConfiguration()
                } else {
                    self.stopAnimateIndicator()
                }
            }
            if animated {
                // stop animate
                self.stopAnimateIndicator()
            }
        }
    }
    
    private func enableAnimate(animated: Bool, tappedButton: UIButton?) {
        if let tappedButton = tappedButton {
            if #available(iOS 15.0, *) {
                tappedButton.configurationUpdateHandler = { button in
                    var config = button.withFilledConfig()
                    config.showsActivityIndicator = true
                    button.configuration = config
                }
                
                tappedButton.setNeedsUpdateConfiguration()
            } else {
                startAnimateIndicator()
            }
        }
        if animated && (tappedButton == nil) {
            // start animate
            startAnimateIndicator()
        }
    }
    
    private func showAlertWith(error: Error) {
        if let error = error as? ApiError {
            if case .jsonDecoder(let errorData) = error {
                if let errorData = errorData {
                    if let jsonObject = try? JSONDecoder().decode(ErrorResponseModel.self, from: errorData) {
                        if let code = jsonObject.errors?.first?.code, code.convert() == "401" {
                            CustomerAuth.shared.logout()
                            if let mainTabBarViewController = UITabBarController.instantiate(withId: "MainTabBarViewController") as? UITabBarController {
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
                        if var title = (jsonObject.errors?.first?.title) {
                            var body = ""
                            if let detail = jsonObject.errors?.first?.detail {
                                body = detail
                            }
                            
                            title = (title == "Invalid Attribute") ? "ویژگی نامعتبر":title
                            showAlerInScreen(title: title, body: body)
                        }
                    }
                }
            }
        }
    }
    
    public func handleRequestByUI<S,R>(_ network: RestfulAPI<S,R>, animated: Bool = false, tappedButton: UIButton? = nil, completion: @escaping (R?) -> Void, error: ((Error)->Void)? = nil) {
        if case .online(_) = connetctionStatus {
            enableAnimate(animated: animated, tappedButton: tappedButton)
            // send request
            network.sendURLSessionRequest { [weak self] (result) in
                self?.disableAnimate(animated: animated, tappedButton: tappedButton)
                // switch server result between success and failed request
                switch result {
                case .success(let response):
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                        // return success result
                        completion(response)
                    })
                case .failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: { [weak self] in
                        self?.showAlertWith(error: error)
                    })
                }
            }
        }
    }
    // monitor Reachability Changed
    func monitorReachabilityChanged() {
        reachability.monitorReachabilityChanges()
    }
}
