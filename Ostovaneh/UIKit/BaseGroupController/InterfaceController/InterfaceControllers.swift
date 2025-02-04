//
//  InterfaceViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/25/1400 AP.
//

import UIKit
import MapKit

protocol InterfaceDelegate: UIViewController {
    func navigationControllerConfiguration()
    func updateThemConfiguration()
    func configUI()
    func updateUI()
}

extension InterfaceDelegate {
    func navigationControllerConfiguration() {
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backButton.setTitleTextAttributes([.font: UIFont.iranSans(.bold, size: 17)], for: .normal)
        backButton.tintColor = .label
    
        navigationItem.backBarButtonItem = backButton
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
    
    func updateThemConfiguration() {
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.iranSans(.bold, size: 17)], for: .normal)
        backButton.tintColor = storeThemColor
        
        navigationItem.backBarButtonItem = backButton
        navigationItem.leftBarButtonItem?.tintColor = storeThemColor
        navigationItem.rightBarButtonItem?.tintColor = storeThemColor
        navigationItem.backBarButtonItem?.tintColor = storeThemColor
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.largeTitleDisplayMode = .never

        if #available(iOS 15, *) {
            //https://stackoverflow.com/questions/69297397/how-to-change-navigation-bar-back-button-colour-ios-15
            let appearance = UINavigationBarAppearance()
            let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
            let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)

            let titleTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.iranSans(.bold, size: 19),
                                       .foregroundColor: storeThemColor]
            let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.iranSans(.bold, size: 24),
                                            .foregroundColor: storeThemColor]

            appearance.configureWithDefaultBackground()
            appearance.titleTextAttributes = titleTextAttributes
            appearance.largeTitleTextAttributes = largeTitleTextAttributes
            
            appearance.backButtonAppearance = backButtonAppearance
            appearance.buttonAppearance = buttonAppearance

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
            navigationItem.backButtonDisplayMode = .minimal
        }
        
        navigationController?.navigationBar.tintColor = storeThemColor
        navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
    }
}

class InterfaceViewController: NetworkViewController, InterfaceDelegate, CustomerAuthDelegate {
    
    let badeCountLabel: UILabel = {
        let badgeCount = UILabel(frame: CGRect(x: 18, y: -05, width: 20, height: 20))
        badgeCount.layer.borderColor = UIColor.clear.cgColor
        badgeCount.layer.borderWidth = 2
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .red
        badgeCount.text = "0"
        
        if let count = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount {
            badgeCount.text = "\(count)"
        }
        
        return badgeCount
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let count = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount {
            badeCountLabel.text = "\(count)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var shouldAutorotate: Bool {
        return false
    }

    func configUI() {
        CustomerAuth.shared.delegate = self
        
        view.backgroundColor = .systemGroupedBackground

        let leftBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftBarButton.setBackgroundImage(UIImage(systemName: "bag"), for: .normal)
        leftBarButton.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        leftBarButton.addSubview(badeCountLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        leftBarButtonItem.tintColor = .label
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        if tabBarController?.selectedIndex == 2 {
            updateThemConfiguration()
        } else {
            navigationControllerConfiguration()
        }
    }

    func updateUI() {
        //
    }
    
    @objc func leftBarButtonTapped() {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        if case .offline = connetctionStatus {
            let content = AlertContent(title: .none, subject: "قطعی اینترنت", description: "دسترسی شما به اینترنت قطع میباشد")
            
            present(AlertContentViewController
                        .instantiate()
                        .alert(content))
            return
        }
        guard let productsCount = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount, productsCount > 0 else {
            showAlerInScreen(body: "سبد خرید شما خالی میباشد")
            return
        }
        
        show(BasketTableViewController
                .instantiate(), sender: nil)
    }
    
    func basketProductCountUpdatedTo(_ number: Int) {
        self.badeCountLabel.text = "\(number)"
    }
}

class InterfaceTableViewController: NetworkTableViewController, InterfaceDelegate, CustomerAuthDelegate {
    let badeCountLabel: UILabel = {
        let badgeCount = UILabel(frame: CGRect(x: 18, y: -05, width: 20, height: 20))
        badgeCount.layer.borderColor = UIColor.clear.cgColor
        badgeCount.layer.borderWidth = 2
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .red
        badgeCount.text = "0"
        
        if let count = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount {
            badgeCount.text = "\(count)"
        }
        return badgeCount
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let count = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount {
            badeCountLabel.text = "\(count)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var shouldAutorotate: Bool {
        return false
    }

    func configUI() {
        CustomerAuth.shared.delegate = self
        
        view.backgroundColor = .systemGroupedBackground
        
        let leftBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftBarButton.setBackgroundImage(UIImage(systemName: "bag"), for: .normal)
        leftBarButton.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        leftBarButton.addSubview(badeCountLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        leftBarButtonItem.tintColor = .label
        
        navigationItem.leftBarButtonItem = leftBarButtonItem

        if tabBarController?.selectedIndex == 2 {
            updateThemConfiguration()
        } else {
            navigationControllerConfiguration()
        }
    }
    
    func updateUI() {
        //
    }
    
    @objc func leftBarButtonTapped() {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        if case .offline = connetctionStatus {
            let content = AlertContent(title: .none, subject: "قطعی اینترنت", description: "دسترسی شما به اینترنت قطع میباشد")
            
            present(AlertContentViewController
                        .instantiate()
                        .alert(content))
            return
        }
        guard let productsCount = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount, productsCount > 0 else {
            showAlerInScreen(body: "سبد خرید شما خالی میباشد")
            return
        }
        
        show(BasketTableViewController
                .instantiate(), sender: nil)
    }
    
    func basketProductCountUpdatedTo(_ number: Int) {
        badeCountLabel.text = "\(number)"
    }
}

class InterfaceCollectionViewController: NetworkCollecitonViewController, InterfaceDelegate, CustomerAuthDelegate {
    let badeCountLabel: UILabel = {
        let badgeCount = UILabel(frame: CGRect(x: 18, y: -05, width: 20, height: 20))
        badgeCount.layer.borderColor = UIColor.clear.cgColor
        badgeCount.layer.borderWidth = 2
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .red
        badgeCount.text = "0"
        
        if let count = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount {
            badgeCount.text = "\(count)"
        }
        
        return badgeCount
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let count = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount {
            badeCountLabel.text = "\(count)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        updateUI()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var shouldAutorotate: Bool {
        return false
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      //
    }

    func configUI() {
        CustomerAuth.shared.delegate = self
        
        view.backgroundColor = .systemGroupedBackground
        
        let leftBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        leftBarButton.setBackgroundImage(UIImage(systemName: "bag"), for: .normal)
        leftBarButton.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        leftBarButton.addSubview(badeCountLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        leftBarButtonItem.tintColor = .label
        
        navigationItem.leftBarButtonItem = leftBarButtonItem

        if tabBarController?.selectedIndex == 2 {
            updateThemConfiguration()
        } else {
            navigationControllerConfiguration()
        }
    }
    
    func updateUI() {
        //
    }
    
    @objc func leftBarButtonTapped() {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        if case .offline = connetctionStatus {
            let content = AlertContent(title: .none, subject: "قطعی اینترنت", description: "دسترسی شما به اینترنت قطع میباشد")
            
            present(AlertContentViewController
                        .instantiate()
                        .alert(content))
            return
        }
        guard let productsCount = CustomerAuth.shared.currentOrderModel?.data?.attributes?.productsCount, productsCount > 0 else {
            showAlerInScreen(body: "سبد خرید شما خالی میباشد")
            return
        }
        
        show(BasketTableViewController
                .instantiate(), sender: nil)
    }
    
    func basketProductCountUpdatedTo(_ number: Int) {
        badeCountLabel.text = "\(number)"
    }
}
