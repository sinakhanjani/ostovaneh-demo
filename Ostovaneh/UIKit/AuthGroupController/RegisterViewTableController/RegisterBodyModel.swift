//
//  RegisterBodyModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/15/1400 AP.
//

import Foundation

// MARK: - RegisterBodyModel
struct RegisterBodyModel: Codable {
    // MARK: - DataClass
    struct DataClass: Codable {
        // MARK: - Attributes
        struct Attributes: Codable {
            let name: String
            let email: String?
            let mobile: String?
            let password: String?
            let ref_by: String?
        }
        
        let type: String
        let attributes: Attributes
    }
    
    let data: DataClass
    
    init(name: String, password: String, email: String?, mobile: String?, ref_by: String?) {
        self.data = DataClass(type: "users", attributes: DataClass.Attributes(name: name, email: email, mobile: mobile, password: password, ref_by: ref_by))
    }
    
    init(data: DataClass) {
        self.data = data
    }
}

