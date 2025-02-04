//
//  SeasonFile.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/28/1400 AP.
//

import Foundation

struct SeasonFile: Codable, Hashable {
    var file: IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>
    let otherFiles: [IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>]?
}
