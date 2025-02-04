//
//  AddFolderModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/19/1400 AP.
//

import Foundation
// MARK: - DataClass
struct MyFolderModel: Codable, Hashable {
    let type, id: String?
    let attributes: Attributes?
    let relationships: Relationships?
    // MARK: - Attributes
    struct Attributes: Codable, Hashable {
        let name: String?
    }
    struct Relationships: Codable, Hashable {
        let products: Product?
        
        struct Product: Codable, Hashable {
            let data: [IncludedTypeModel<EMPTYHASHABLEMODEL,EMPTYHASHABLEMODEL>]?
        }
    }
}

// MARK: - AddFolderResponseModel
struct AddFolderResponseModel: Codable, Hashable {
    
    let data: MyFolderModel?
    
    static private var archiveURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("folder").appendingPathExtension("fl")
    }
    
    static private func encode(items: [AddFolderResponseModel], directory dir: URL) {
        let propertyListEncoder = PropertyListEncoder()
        if let encodedProduct = try? propertyListEncoder.encode(items) {
            try? encodedProduct.write(to: dir, options: .noFileProtection)
        }
    }
    
    static private func decode(directory dir: URL) -> [AddFolderResponseModel]? {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedProductData = try? Data.init(contentsOf: dir), let decodedProduct = try? propertyListDecoder.decode([AddFolderResponseModel].self, from: retrievedProductData) {
            return decodedProduct
        }
        
        return nil
    }
    
    // CRUD
    static public var folderItems: [AddFolderResponseModel] {
        get {
            return AddFolderResponseModel.decode(directory: AddFolderResponseModel.archiveURL) ?? []
        }
        set {
            AddFolderResponseModel.encode(items: newValue, directory: AddFolderResponseModel.archiveURL)
        }
    }
    
    static func fetchRecordedFolders() ->[AddFolderResponseModel] {
        return folderItems
    }
    
    static func addFolder(item: AddFolderResponseModel) {
        if let _ = folderItems.first(where: { i in
            i.data?.id == item.data!.id!
        }) {
            // its added befor
            return
        }
        folderItems.append(item)
    }
    
    static func removeProduct(item: ProductResponseModel) {
        if let index = folderItems.firstIndex(where: { $0.data?.id == item.data!.id! }) {
            folderItems.remove(at: index)
        }
    }
    
    static func removeAllFolders() {
        folderItems = []
    }
}
