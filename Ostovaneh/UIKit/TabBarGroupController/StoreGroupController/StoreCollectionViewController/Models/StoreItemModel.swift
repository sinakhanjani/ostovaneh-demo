//
//  StoreInternalModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/30/1400 AP.
//

import Foundation

enum StoreItemModel: Hashable {
    case category(IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>)
    case banner(IncludedTypeModel<ImageAttributeModel,EMPTYHASHABLEMODEL>)
    case product(IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>)
}
