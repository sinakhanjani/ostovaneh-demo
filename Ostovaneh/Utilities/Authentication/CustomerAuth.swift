//
//  Auth.swift
//
//  Created by Sina khanjani on 2/31/1400 AP.
//

import Foundation
import RestfulAPI

protocol CustomerAuthDelegate: AnyObject {
    func basketProductCountUpdatedTo(_ number: Int)
}

struct CustomerAuth {
    public static var shared = CustomerAuth()
    
    public weak var delegate: CustomerAuthDelegate?
    
    private var user: Authentication = .user
    
    public var loginResponseModel: LoginResponseModel? {
        willSet {
            currentOrderModel = newValue?.orderResponseModel
        }
    }
    public var currentOrderModel: OrderResponseModel? {
        willSet {
            if let productsCount = newValue?.data?.attributes?.productsCount {
                delegate?.basketProductCountUpdatedTo(productsCount)
            }
        }
    }
    
    public var isLogin: Bool {
        user.isLogin
    }
    
    public var token: String? {
        user.token
    }
    
    public mutating func registerUser(with token: String) {
        user.register(with: token)
    }
    
    public mutating func logout() {
        // remove all caches and downloads from disk space
        let recordedProducts = ProductResponseModel.fetchRecordedProducts()
        recordedProducts.forEach { productResponseModel in
            ProductDetailCollectionViewController.deleteAllFiles(info: productResponseModel)
        }
        // remove all save product models
        ProductResponseModel.removeAllProducts()
        AddFolderResponseModel.removeAllFolders()
        folderDict = [:]
        // sigout google
        GoogleAuthenticationController.signOut()
        // logout token users
        user.logout()
        // remove init model
        loginResponseModel = nil
    }
}
