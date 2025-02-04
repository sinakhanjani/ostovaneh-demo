//
//  ProductSortType.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/19/1400 AP.
//

import Foundation

enum ProductSortType: String, CaseIterable {
    case new
    case free
    case topsale
    case offer
    
    var title: String {
        switch self {
        case .new: return "جدیدترین‌ ها"
        case .free: return "رایگان‌ ها"
        case .topsale: return "پرفروش‌ ترین‌ ها"
        case .offer: return "پیشنهادی به شما"
        }
    }
}
