//
//  MyProductResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/19/1400 AP.
//

import Foundation

struct MyProductResponseModel: Codable, Hashable {
    let data: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]?
}
