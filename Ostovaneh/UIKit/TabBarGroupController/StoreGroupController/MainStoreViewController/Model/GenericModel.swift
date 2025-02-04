//
//  GenericModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/19/1400 AP.
//

import Foundation

// ParentDataTypeModel Generic Model
struct ParentDataTypeModel<MetaType: Codable & Hashable, DataType: Codable & Hashable>: Codable, Hashable {
    let meta: MetaTypeModel<MetaType>?
    let data: DataType?
    let errors: [ErrorModel]?
}
// DataTypeModel Generic Model
struct DataTypeModel: Codable, Hashable {
    let id: String?
    let type: String?
}
// MetaTypeModel Generic Model
struct MetaTypeModel<T: Codable & Hashable>: Codable, Hashable {
    let pivots: [T]?
}
// IncludedTypeModel Generic Model
struct IncludedTypeModel<Attribute: Codable & Hashable, Relationships: Codable & Hashable>: Codable, Hashable {
    let id: String?
    let type: String?
    var attributes: Attribute?
    var relationships: Relationships?
}
// StringOrInt Enumuration
enum StringOrInt: Codable, Hashable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        if let int = try?
            decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        if let string = try?
            decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        throw Error.couldNotFindStringOrInt
    }
    
    enum Error: Swift.Error {
        case couldNotFindStringOrInt
    }
    
    func convert() -> String {
        switch self {
        case .int(let x):
            return String(x)
        case .string(let x):
            return x
        }
    }
}
