//
//  ImageModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/6/1400 AP.
//

import Foundation


struct ImageAttributeModel: Codable, Hashable {
    let name: String
    let url: String
}

struct ImageModel: Codable, Hashable {
    let url: String
}
