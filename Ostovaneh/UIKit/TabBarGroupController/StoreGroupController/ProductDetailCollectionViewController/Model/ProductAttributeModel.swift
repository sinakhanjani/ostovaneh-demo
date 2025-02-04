//
//  ProductResponseModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/17/1400 AP.
//

import Foundation
import UIKit

// MARK: - ProductResponseModel
struct ProductAttributeModel: Codable, Hashable {
    let name: String
    
    let authorsName: String? // nevisande
    let translatorsName: String? // motarjem
    let publisherName: String? // nasher

    let rialOldPrice: Double?
    let rialCurrentPrice: Double?
    let usdOldPrice: Double?
    let usdCurrentPrice: Double?
    let rank: Double?
    let scoresCount: Double?
    var thumbnailImageURL: String?
    let catIds: String?
    let isSaved: String?
    let catKey: String?
    let isbn: String?
    let body: String?
    let url: String?
    
    let productType: ProductType
    let fileType: String?
    
    let print_price: String? // qeymat chapi
    let age_range: String? // goroh seni
    let file_page_count: String? // tedad safahat
    let file_volume: String? // hajm
    let file_time: String? // modat zaman
    let files_count: String? // tedad qesmat
    let hasOtherVersions: String? // false&true string
    let voice_actor: String? // seda pisheh
    let audio_publisher: String? // nasher sooti
    let release_date: Int? // sale enteshar
    let producer: String? // tolid konande
    let actor: String? // mojri

    let review_time: Double? // modat zamani k mitavand test moshahede konad
    var savedThumbnailImageURL: Data? = nil
    var folderIDs: String? = nil
//
    
    public var fileTypeEnum: FileType? {
        if let fileType = fileType {
            return FileType.init(rawValue: fileType)
        }
        
        return nil
//        else {
//            return FileType.init(rawValue: "EPUB")
//        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, rank, body
        
        case authorsName = "authors_string"
        case translatorsName = "translators_string"
        case publisherName = "publisher_string"
        
        case rialOldPrice = "old_price"
        case rialCurrentPrice = "price"
        case usdOldPrice = "old_priced"
        case usdCurrentPrice = "priced"
        case scoresCount = "scores_count"
        case thumbnailImageURL = "thumbnail_url"
        case productType = "product_type"
        case fileType = "file_type"
        case catIds = "cat_ids"
        case isSaved
        case catKey = "cat_key"
        case isbn, url
        
        case age_range,print_price,file_page_count,file_volume,file_time,files_count,hasOtherVersions,voice_actor,audio_publisher,release_date,producer,actor,review_time
    }
    
    enum Error: Swift.Error {
        case couldNotFindType
    }
}

struct ProductHeader: Hashable, Codable {
    let id: String
    let key: String
    let faKey: String
    let name: String
}

struct ProductDetail: Hashable, Codable {
    let title: String
    let key: String
    let value: String
}

enum ProductType: String , Codable, Hashable {
    case video = "video"
    case ebook = "ebook"
    case audio = "audio"
    case ostovane = "ostovane" // aya zamani ke "file_type":"PDF" ? productID:"966"
    
    var title: String {
        switch self {
        case .video:
            return "کتابفیلم"
        case .ebook:
            return "متنی"
        case .audio:
            return "کتابگو"
        case .ostovane:
            return "متنی"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .video:
            return UIImage(systemName: "video")
        case .ebook:
            return UIImage(systemName: "book.closed.fill")
        case .audio:
            return UIImage(systemName: "headphones")
        case .ostovane:
            return UIImage(systemName: "book.closed")
        }
    }
}

enum FileType: String , Codable, Hashable {
    case MP4,EPUB,PDF,ZIP,MP3
    
    var title: String {
        switch self {
        case .MP4:
            return "کتاب فیلم"
        case .EPUB:
            return "EPUB"
        case .PDF:
            return "متنی"
        case .ZIP:
            return "کتابگو"
        case .MP3:
            return "کتاب‌ صوتی"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .MP4:
            return UIImage(systemName: "video")!
        case .EPUB:
            return UIImage(systemName: "text.book.closed")!
        case .PDF:
            return UIImage(systemName: "book.closed.fill")!
        case .ZIP:
            return UIImage(systemName: "ipad.badge.play")!
        case .MP3:
            return UIImage(systemName: "headphones")!
        }
    }
}
