//
//  FileModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/6/1400 AP.
//

import Foundation

// MARK: - UserAttributeModel
struct FileAttributeModel: Codable, Hashable {
    let url, directURL, checkTrialURL: String?
    let relatedFrom, relatedTo: Int?
    let relatedFileID: String
//    let relatedFileName: JSONNull?
    let name, fileExtension: String?
    let originalExtension: String
//    let volume, time: JSONNull?

    enum CodingKeys: String, CodingKey {
        case url
        case directURL = "direct_url"
        case checkTrialURL = "check_trial_url"
        case relatedFrom = "related_from"
        case relatedTo = "related_to"
        case relatedFileID = "related_file_id"
//        case relatedFileName = "related_file_name"
        case name
        case fileExtension = "extension"
        case originalExtension = "original_extension"
//        case volume, time
    }
}
