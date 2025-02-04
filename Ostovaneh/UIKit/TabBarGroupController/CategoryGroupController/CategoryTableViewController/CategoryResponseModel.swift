//
//  CategoryResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/17/1400 AP.
//

import Foundation

// MARK: - CategoryResponseModelElement
struct CategoryResponseModelElement: Codable, Hashable {
    let id, name: String
    let children: [CategoryResponseModelElement]
}

typealias CategoryResponseModel = [CategoryResponseModelElement]
