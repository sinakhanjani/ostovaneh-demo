//
//  FetchCategoryRequestInjection.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/17/1400 AP.
//

import RestfulAPI
import UIKit

protocol FetchCategoryRequestInjection: RestfulAPIDelegate {
    func fetchCategoryData(catId: String, sortBy: ProductSortType?, skip: Int?, completion: ((_ results: MainSchemaResponseModel?) -> Void)?)
}

extension FetchCategoryRequestInjection {
    func fetchCategoryData(catId: String, sortBy: ProductSortType? = nil, skip: Int? = nil, completion: ((_ results: MainSchemaResponseModel?) -> Void)?) {
        var queries = ["v":"2",
                       "skip":"0",
                       "include":["products","children","banners"].includes()]
        if let sortBy = sortBy {
            queries.updateValue(sortBy.rawValue, forKey: "psort")
        }
        if let skip = skip {
            queries.updateValue(String(skip), forKey: "skip")
        }
        
        let network = RestfulAPI<EMPTYMODEL,MainSchemaResponseModel>.init(path: "/v1/categories/\(catId)")
            .with(queries: queries)
        
        handleRequestByUI(network, animated: true) { result in
            completion?(result)
        }
    }
}
