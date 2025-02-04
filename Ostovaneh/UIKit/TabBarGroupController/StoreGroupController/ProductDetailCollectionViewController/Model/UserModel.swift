//
//  UserModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/6/1400 AP.
//

import Foundation

struct UserAttributeModel: Codable, Hashable {
    let name, mobile, email: String?
    let jwtToken: String?
    let refCode: String
    let imageURL: String?
    let metaString: String?

    enum CodingKeys: String, CodingKey {
        case name, mobile, email
        case jwtToken = "jwt_token"
        case refCode = "ref_code"
        case imageURL = "imageUrl"
        case metaString = "meta_string"
    }
}

