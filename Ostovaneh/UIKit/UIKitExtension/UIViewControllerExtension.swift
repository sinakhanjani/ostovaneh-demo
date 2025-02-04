//
//  UIViewExtension.swift
//  Master
//
//  Created by Sina khanjani on 10/9/1399 AP.
//
import UIKit
import ProgressHUD

extension UIViewController {
    /// Instantiate ViewController by identifier on storyboard
    public static func instantiate(storyboard name: String = "Main") -> Self {
        func create<T : UIViewController> (type: T.Type) -> T {
            let uiStoryboard = UIStoryboard(name: name, bundle: nil)
            let vc: T = uiStoryboard.instantiateViewController(identifier:  String(describing: self)) { (coder) -> T? in
                T(coder: coder)
            }
            
            return vc
        }
        
        return create(type: self)
    }
    /// Instantiate View Controller by storyboard identifier ID
    public static func instantiate(storyboard name: String = "Main", withId id: String) -> UIViewController {
        let uiStoryboard = UIStoryboard(name: name, bundle: nil)
        let vc = uiStoryboard.instantiateViewController(withIdentifier: id)
        
        return vc
    }
    /// Return current ViewController identifierID
    @objc class var identifier: String {
        return String(describing: self)
    }
    
    public func present(_ viewController: UIViewController) {
        present(viewController, animated: true)
    }
}

extension UIViewController {
    func register(_ tableView: UITableView, with cell: UITableViewCell.Type) {
        let nib = UINib(nibName: cell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cell.identifier)
    }
    
    func register(_ collectionView: UICollectionView, with cell: UICollectionViewCell.Type) {
        let nib = UINib(nibName: cell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cell.identifier)
    }
}

extension UIViewController {
    func startAnimateIndicator() {
        ProgressHUD.show()
    }
    
    func stopAnimateIndicator() {
        ProgressHUD.dismiss()
    }
}

extension UIViewController {
    func showAlerInScreen(title: String = "", body: String) {
        let alertContent = AlertContent(title: .none, subject: title, description: body)
        present(WarningContentViewController
                    .instantiate()
                    .alert(alertContent))
    }
}
