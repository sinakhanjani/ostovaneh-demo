//
//  ProductResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/6/1400 AP.
//

import Foundation
import UIKit

struct ProductResponseModel: Hashable, Codable {
    static private var archiveURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("product").appendingPathExtension("pr")
    }
    
    static private func encode(items: [ProductResponseModel], directory dir: URL) {
        let propertyListEncoder = PropertyListEncoder()
        if let encodedProduct = try? propertyListEncoder.encode(items) {
            try? encodedProduct.write(to: dir, options: .noFileProtection)
        }
    }
    
    static private func decode(directory dir: URL) -> [ProductResponseModel]? {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedProductData = try? Data.init(contentsOf: dir), let decodedProduct = try? propertyListDecoder.decode([ProductResponseModel].self, from: retrievedProductData) {
            return decodedProduct
        }
        
        return nil
    }
    
    // CRUD
    static private var productItems: [ProductResponseModel] {
        get {
            return ProductResponseModel.decode(directory: ProductResponseModel.archiveURL) ?? []
        }
        set {
            ProductResponseModel.encode(items: newValue, directory: ProductResponseModel.archiveURL)
        }
    }
    
    static func fetchRecordedProducts() ->[ProductResponseModel] {
        return productItems
    }
    
    static func addProduct(item: ProductResponseModel) {
        if let _ = productItems.first(where: { i in
            i.data?.id == item.data!.id!
        }) {
            // its added befor
            return
        }
        // if not in list so added
        //SINA
        let includedStr = item.included.map { i -> String in
            switch i {
            case .categories(let x):
                let jsonData = try! JSONEncoder().encode(x)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString
            case .users(let x):
                let jsonData = try! JSONEncoder().encode(x)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString
            case .scores(let x):
                let jsonData = try! JSONEncoder().encode(x)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString
            case .files(let x):
                let jsonData = try! JSONEncoder().encode(x)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString
            case .images(let x):
                let jsonData = try! JSONEncoder().encode(x)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString
            case .languages(let x):
                let jsonData = try! JSONEncoder().encode(x)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                return jsonString
            }
        }
        var addedItem = item
        
        addedItem.includedstr = includedStr
        if let urlStr = addedItem.data?.attributes?.thumbnailImageURL {
            if let url = URL(string: urlStr) {
                if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
                    if let data = cachedImage.jpegData(compressionQuality: 0.6) {
                        addedItem.data?.attributes?.savedThumbnailImageURL = data
                    }
                }
            }
        }

        productItems.append(addedItem)
    }
    
    static func update(data: IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>) {
        if let index = productItems.firstIndex(where: { i in
            i.data?.id == data.id!
        }) {
            var productI = productItems[index]
            productI.data = data
            productItems[index] = productI
        }
    }
    
    static func removeProduct(item: ProductResponseModel) {
        if let index = productItems.firstIndex(where: { $0.data?.id == item.data!.id! }) {
            productItems.remove(at: index)
        }
    }
    
    static func removeAllProducts() {
        productItems = []
    }
        
    var data: IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>?
    var included: [ProductIncludedModel]
    var line: Int? = 3
    var includedstr: [String]? = nil
}

enum ProductIncludedModel: Codable, Hashable {
    case categories(IncludedTypeModel<CategoryAttributeModel,EMPTYHASHABLEMODEL>)
    case users(IncludedTypeModel<UserAttributeModel,EMPTYHASHABLEMODEL>)
    case scores(IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>)
    case files(IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>)
    case images(IncludedTypeModel<ImageAttributeModel,EMPTYHASHABLEMODEL>)
    case languages(IncludedTypeModel<LanguageAttributeModel,EMPTYHASHABLEMODEL>)
    
    init(from decoder: Decoder) throws {
        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<CategoryAttributeModel,EMPTYHASHABLEMODEL>.self) {
            self = .categories(x)
            return
        }
        
        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<UserAttributeModel,EMPTYHASHABLEMODEL>.self) {
            self = .users(x)
            return
        }
        
        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>.self) {
            self = .scores(x)
            return
        }
        
        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>.self) {
            self = .files(x)
            return
        }
        
        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<ImageAttributeModel,EMPTYHASHABLEMODEL>.self) {
            self = .images(x)
            return
        }
        
        if let x = try?
            decoder.singleValueContainer().decode(IncludedTypeModel<LanguageAttributeModel,EMPTYHASHABLEMODEL>.self) {
            self = .languages(x)
            return
        }
        
        throw Error.couldNotFindType
    }
    
    enum Error: Swift.Error {
        case couldNotFindType
    }
}

extension ProductResponseModel {
    /// filter heder line like: 1.authorsName,2.translatorsName, and more button
    public var filterProductHeaders: [ProductHeader] {
        var items = [ProductHeader]()
        included.forEach { productIncludedModel in
            if case .users(let user) = productIncludedModel {
                // add author (nevisande)
                if let author = data?.attributes?.authorsName {
                    if user.attributes?.name == author {
                        let item = ProductHeader(id: user.id!, key: "authors", faKey: "نویسنده", name: author)
                        items.append(item)
                    }
                }
                // add translator (motarjem)
                if let translator = data?.attributes?.translatorsName {
                    if user.attributes?.name == translator {
                        let item = ProductHeader(id: user.id!, key: "translators", faKey: "مترجم", name: translator)
                        items.append(item)
                    }
                }
            }
        }
        
        return items
    }
    
    public var productCategories: [IncludedTypeModel<CategoryAttributeModel,EMPTYHASHABLEMODEL>] {
        let catsIncluded = filterIncludedBy(.categories, included: included)
        let categories = getItemOfIncluded(inputs: catsIncluded) as! [IncludedTypeModel<CategoryAttributeModel,EMPTYHASHABLEMODEL>]
        
        return categories
    }
    
    public var scores: [IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>] {
        let scoresIncluded = filterIncludedBy(.scores, included: included)
        let scores = getItemOfIncluded(inputs: scoresIncluded) as! [IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>]
        
        return scores
    }
    
    public var files: [IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>] {
        let reachability = Reachability()
        switch reachability.connectionStatus() {
        case .offline:
            if let includedStr = includedstr {
                let items = includedStr.map { item -> ProductIncludedModel in
                    let x =  item.toJSONObject(typeOf: ProductIncludedModel.self)!
                    return x
                }
                let filesIncluded = filterIncludedBy(.files, included: items)
                let files = getItemOfIncluded(inputs: filesIncluded) as! [IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>]
                
                return files
            } else {
                return []
            }
        default:
            let filesIncluded = filterIncludedBy(.files, included: included)
            let files = getItemOfIncluded(inputs: filesIncluded) as! [IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>]
            
            return files
        }
    }
    
    public var seasonFiles: [SeasonFile] {
        func findRelatedFileTo(fileID: String) -> [IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>] {
            files.filter { $0.attributes?.relatedFileID == fileID }
        }
        var seasons: [SeasonFile] = []

        if files.count == 1 {
            seasons.append(SeasonFile(file: files[0], otherFiles: nil))
        } else {
            files.forEach { file in
                if (file.attributes?.relatedFileID.isEmpty ?? true) {
                    let otherFiles = findRelatedFileTo(fileID: file.id!).sorted { $0.attributes?.relatedFrom ?? 0 < $1.attributes?.relatedFrom ?? 0 }
                    seasons.append(SeasonFile(file: file, otherFiles: otherFiles))
                }
            }
        }
        
        return seasons
    }
    /// filter product informations section
    public func productInformations(parentCatID: String) -> [ProductDetail] {
        var items = [ProductDetail]()
        // category inject
        let catsIncluded = filterIncludedBy(.categories, included: included)
        let categories = getItemOfIncluded(inputs: catsIncluded) as! [IncludedTypeModel<CategoryAttributeModel,EMPTYHASHABLEMODEL>]
        if let cat = categories.first(where: { i in
            i.id == parentCatID
        }) {
            if let name = cat.attributes?.name {
                let item = ProductDetail(title: "دسته‌بندی", key: "categories", value: name)
                items.append(item)
            }
        } else {
            if !categories.isEmpty {
                let cat = categories[0]
                if let name = cat.attributes?.name {
                    let item = ProductDetail(title: "دسته‌بندی", key: "categories", value: name)
                    items.append(item)
                }
            }
        }
        // qeymat noskhe chapi
        if let x = data?.attributes?.print_price {
            if x != "0" {
                let item = ProductDetail(title: "قیمت نسخه چاپی", key: "print_price", value: x)
                items.append(item)
            }
        }
        // seda pishe
        if let x = data?.attributes?.voice_actor {
            let item = ProductDetail(title: "صدا پیشه", key: "voice_actor", value: x)
            items.append(item)
        }
        // tedad qesmatha
        if let x = data?.attributes?.files_count {
            let item = ProductDetail(title: "تعداد قسمت‌ها", key: "files_count", value: x)
            items.append(item)
        }
        // mojri
        if let x = data?.attributes?.actor {
            let item = ProductDetail(title: "مجری", key: "actor", value: x)
            items.append(item)
        }
        // tedad safahat
        if let x = data?.attributes?.file_page_count {
            let item = ProductDetail(title: "تعداد صفحات", key: "file_page_count", value: x)
            items.append(item)
        }
        // modat zaman
        if let x = data?.attributes?.file_time {
            let item = ProductDetail(title: "مدت زمان", key: "file_time", value: x)
            items.append(item)
        }
        // hajm
        if let x = data?.attributes?.file_volume {
            let item = ProductDetail(title: "حجم", key: "file_volume", value: x)
            items.append(item)
        }
        // goroh seni
        if let x = data?.attributes?.age_range {
            let item = ProductDetail(title: "گروه سنی", key: "age_range", value: x)
            items.append(item)
        }
        // nasher
        if let x = data?.attributes?.publisherName {
            let item = ProductDetail(title: "ناشر", key: "publisherName", value: x)
            items.append(item)
        }
        //zaban
        let langIncluded = filterIncludedBy(.languages, included: included)
        let langs = getItemOfIncluded(inputs: langIncluded) as! [IncludedTypeModel<LanguageAttributeModel,EMPTYHASHABLEMODEL>]
        if !langs.isEmpty {
            if let name = langs[0].attributes?.name {
                let item = ProductDetail(title: "زبان", key: "languages", value: name)
                items.append(item)
            }
        }
        // nasher sooti
        if let x = data?.attributes?.audio_publisher {
            let item = ProductDetail(title: "ناشر صوتی", key: "audio_publisher", value: x)
            items.append(item)
        }
        // tolid konande
        if let x = data?.attributes?.producer {
            let item = ProductDetail(title: "تولید کننده", key: "producer", value: x)
            items.append(item)
        }
        // sale enteshar ya sale tolid
        if let x = data?.attributes?.release_date {
            let item = ProductDetail(title: "سال انتشار", key: "release_date", value: "\(x)")
            items.append(item)
        }
        
        return items
    }
    
    private func filterIncludedBy(_ type: IncludedType, included: [ProductIncludedModel]) -> [ProductIncludedModel] {
        var items = [ProductIncludedModel]()
        
        included.forEach { item in
            switch type {
            case .categories:
                if case .categories(_) = item {
                    items.append(item)
                }
            case .users:
                if case .users(_) = item {
                    items.append(item)
                }
            case .scores:
                if case .scores(_) = item {
                    items.append(item)
                }
            case .files:
                if case .files(_) = item {
                    items.append(item)
                }
            case .images:
                if case .images(_) = item {
                    items.append(item)
                }
                break
            case .languages:
                if case .languages(_) = item {
                    items.append(item)
                }
            }
        }
        
        return items
    }
    
    private func getItemOfIncluded(inputs: [ProductIncludedModel]) -> [Any] {
        var items = [Any]()
        
        inputs.forEach { productIncludedModel in
            switch productIncludedModel {
            case .categories(let x):
                items.append(x)
            case .users(let x):
                items.append(x)
            case .scores(let x):
                items.append(x)
            case .files(let x):
                items.append(x)
            case .images(let x):
                items.append(x)
            case .languages(let x):
                items.append(x)
            }
        }
        
        return items
    }
        
    enum IncludedType {
        case categories,users,scores,files,images,languages
    }
}
