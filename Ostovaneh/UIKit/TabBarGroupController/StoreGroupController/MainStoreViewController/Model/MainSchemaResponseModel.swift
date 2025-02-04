//
//  MainSchemResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/17/1400 AP.
//

import Foundation
import RestfulAPI

struct MainSchemaResponseModel: Codable, Hashable {
    let data: MainSchemaDataModel?
    let included: [MainSchemaIncludedModel]?
}

// Included Model
enum MainSchemaIncludedModel: Codable, Hashable {
    case products(IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>)
    case categories(IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>)
    case images(IncludedTypeModel<ImageAttributeModel,EMPTYHASHABLEMODEL>)
    
    init(from decoder: Decoder) throws {
        if let products = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>.self) {
            self = .products(products)
            return
        }
        if let images = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<ImageAttributeModel,EMPTYHASHABLEMODEL>.self) {
            self = .images(images)
            return
        }
        if let categories = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>.self) {
            self = .categories(categories)
            return
        }
        
        throw Error.couldNotFindType
    }
    enum Error: Swift.Error {
        case couldNotFindType
    }
}
// Data Model
struct MainSchemaDataModel: Codable, Hashable {
    // Relationship
    struct MainSchemaDataRelationshipModel: Codable, Hashable {
        let products: ParentDataTypeModel<ProductPivotMode,[DataTypeModel]>?
        let children: ParentDataTypeModel<DataTypeModel,[DataTypeModel]>?
        let parent: ParentDataTypeModel<DataTypeModel,DataTypeModel>?
        let banners: ParentDataTypeModel<BannerPivotModel,[DataTypeModel]>?
    }
    // Objects
    let id: String?
    let type: String?
    let attributes: CategoryAttributeModel?
    let relationships: MainSchemaDataRelationshipModel?
}
struct ProductPivotMode: Codable, Hashable {
    let id: String?
    let cat_key: StringOrInt?
}
// MARK: - BannerPivotModel
struct BannerPivotModel: Codable, Hashable {
    let id, key: String?
    let value: String?
    let subCategory: String?
    let sorted, phoneHeight: Int?

    enum CodingKeys: String, CodingKey {
        case id, key, value
        case subCategory = "sub_category"
        case sorted
        case phoneHeight = "phone_height"
    }
}
// CategoryAttributeModel
struct CategoryAttributeModel: Codable, Hashable {
    let name: String?
    let meta_string: String?
    let slug: String?
    let iconUrl: String?
    let banners_string: String
}

struct IncludedCategoryProductDataModel: Codable, Hashable {
    let products: ParentDataTypeModel<EMPTYHASHABLEMODEL,[DataTypeModel]>
}
