//
//  SimularProductModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/7/1400 AP.
//

import Foundation

struct SimularProductModel: Hashable, Codable {
    let data: [SearchIncludedModel]?
    
    var productsIncludedModel: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>] {
        var items = [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]()
        
        data?.forEach({ item in
            if case .products(let x) = item {
                items.append(x)
            }
        })
        
        return items
    }
}
