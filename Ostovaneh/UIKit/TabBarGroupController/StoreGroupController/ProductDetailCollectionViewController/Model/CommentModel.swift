//
//  CommentModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/28/1400 AP.
//

import Foundation

struct CommentAttributeModel: Codable, Hashable {
    let comment: String
    let rank: Double
}

struct CommentRelationshipModel: Codable, Hashable {
    let product: ParentDataTypeModel<EMPTYHASHABLEMODEL,DataTypeModel>
    let parent: ParentDataTypeModel<EMPTYHASHABLEMODEL,DataTypeModel>?
}
