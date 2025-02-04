//
//  SearchResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/17/1400 AP.
//

import Foundation

// MARK: - SearchResponseModel
struct SearchResponseModel: Hashable, Codable {
    let included: [SearchIncludedModel]?
    
    var productsIncludedModel: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>] {
        var items = [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]()
        
        included?.forEach({ item in
            if case .products(let x) = item {
                items.append(x)
            }
        })
        
        return items
    }
}

enum SearchIncludedModel: Codable, Hashable {
    case products(IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>)
    case users(IncludedTypeModel<EMPTYHASHABLEMODEL,EMPTYHASHABLEMODEL>)
    
    init(from decoder: Decoder) throws {
        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>.self) {
            self = .products(x)
            return
        }

        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<EMPTYHASHABLEMODEL,EMPTYHASHABLEMODEL>.self) {
            self = .users(x)
            return
        }
        
        throw Error.couldNotFindType
    }
    
    enum Error: Swift.Error {
        case couldNotFindType
    }
}
