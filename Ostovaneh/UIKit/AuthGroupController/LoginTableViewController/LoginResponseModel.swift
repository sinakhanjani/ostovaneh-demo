//
//  LoginResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/14/1400 AP.
//

import Foundation

// MARK: - LoginResponseModel
struct LoginResponseModel: Codable {
    public var credit: Int?
    public let bannerURL: String?
    public let token: String?

    private let user: String
    private let order: String?
    private let products: String?
    private let folders: String?
    
    public var userResponseModel: UserResponseModel? {
        return user.toJSONObject(typeOf: UserResponseModel.self)
    }

    public var orderResponseModel: OrderResponseModel? {
        return order?.toJSONObject(typeOf: OrderResponseModel.self)
    }
    
    public var foldersResponseModel: FolderResponseModel? {
        return folders?.toJSONObject(typeOf: FolderResponseModel.self)
    }
    
    public var purchasedProductIds: [String]? {
        if let purchased_products = userResponseModel?.data?.attributes?.meta_string?.toJSONObject(typeOf: UserMetaString.self)?.purchased_products {
            let x = purchased_products.components(separatedBy: ",")
            
            return x
        }
        
        return nil
    }
    
    public var viewedProductIds: [String]? {
        if let viewed_products = userResponseModel?.data?.attributes?.meta_string?.toJSONObject(typeOf: UserMetaString.self)?.viewed_products {
            let x = viewed_products.components(separatedBy: ",")
            
            return x
        }
        
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case user, credit, order, token
        case bannerURL = "banner_url"
        case products, folders
    }
}

// MARK: - UserResponseModel
struct UserResponseModel: Codable {
    struct UserData: Codable {
        struct Attributes: Codable {
            let name: String?
            let mobile: String?
            let email: String?
            let ref_code: String?
            let imageUrl: String?
            let jwt_token: String?
            let meta_string: String?
        }
        
        let attributes: Attributes?
        let id: String?
        let type: String?
    }
    
    let data: UserData?
}

struct UserMetaString: Codable, Hashable {
    let purchased_products: String?
    let viewed_products: String?
}

// MARK: - OrderResponseModel
struct OrderResponseModel: Codable, Hashable {
    var data: IncludedTypeModel<OrderAttributeModel,OrderRelationshipModel>?
    var included: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]?
    let errors: [ErrorModel]?
}
struct OrderRelationshipModel: Codable, Hashable {
    struct ProductRelationshipModel: Codable, Hashable {
        var data: [DataTypeModel]?
        
        mutating func removeProductFromList(productID: String) {
            data = data?.filter({ $0.id != productID })
        }
        
        mutating func addProductToList(product: IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>) {
            if let _ = data {
                data!.append(DataTypeModel(id: product.id, type: product.type))
            } else {
                data = [DataTypeModel(id: product.id, type: product.type)]
            }
        }
    }
    
    var products: ProductRelationshipModel?
    var user: ParentDataTypeModel<EMPTYHASHABLEMODEL,DataTypeModel>?
}
struct OrderAttributeModel: Codable, Hashable {
    var status, rand, name: String?
    var basePrice, basePriced, discountPrice, discountPriced: Double?
    var finalPrice, finalPriced: Double?
    var productsCount: Int?
    var currency: String?

    enum CodingKeys: String, CodingKey {
        case status, rand, name
        case basePrice = "base_price"
        case basePriced = "base_priced"
        case discountPrice = "discount_price"
        case discountPriced = "discount_priced"
        case finalPrice = "final_price"
        case finalPriced = "final_priced"
        case productsCount = "products_count"
        case currency
    }
}

struct FolderResponseModel: Codable, Hashable {
    let data: [MyFolderModel]?
}
