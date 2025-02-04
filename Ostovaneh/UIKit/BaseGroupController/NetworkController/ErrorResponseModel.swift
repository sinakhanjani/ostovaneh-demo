//
//  ErrorResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/18/1400 AP.
//

import Foundation
struct ErrorModel: Codable, Hashable {
    let title: String?
    let status: String?
    let detail: String?
    let code: StringOrInt?
}
struct ErrorResponseModel: Codable, Hashable {
    
    let errors: [ErrorModel]?
}
