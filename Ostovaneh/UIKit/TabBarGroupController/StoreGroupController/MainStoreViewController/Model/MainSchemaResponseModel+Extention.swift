//
//  MainSchemaResponseModel+Extention.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/19/1400 AP.
//

import Foundation

struct EMPTYHASHABLEMODEL: Codable, Hashable {
    
}

extension MainSchemaResponseModel {
    func filterAttributeBy(categoryKey: String) -> (categoryIncludedModel: IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>?, productsIncludedModel: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>], imagesIncludedModel: [IncludedTypeModel<ImageAttributeModel,EMPTYHASHABLEMODEL>]) {
        var productsIncludedModel = [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]()
        var imagesIncludedModel = [IncludedTypeModel<ImageAttributeModel,EMPTYHASHABLEMODEL>]()
        var categoryIncludedModel: IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>?
        
        // check for catID in default params filter
        ProductSortType.allCases.forEach { productSortType in
            if productSortType.rawValue == categoryKey {
                let defaultCategoryAttributeModel = CategoryAttributeModel(name: productSortType.title, meta_string: nil, slug: nil, iconUrl: nil, banners_string: "")
                categoryIncludedModel = IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>.init(id: productSortType.rawValue, type: "categories", attributes: defaultCategoryAttributeModel)
            }
        }
        
        // scan included
        if let productPivots = data?.relationships?.products?.meta?.pivots {
            let productsID = productPivots.filter { $0.cat_key?.convert() == categoryKey }.map(\.id!)
            included?.forEach { item  in
                if case .products(let productIncludeModel) = item {
                    if productsID.contains(productIncludeModel.id!) {
                        productsIncludedModel.append(productIncludeModel)
                    }
                }
                
                if case .categories(let categoriesIncludeModel) = item {
                    if categoryKey == categoriesIncludeModel.id {
                        categoryIncludedModel = categoriesIncludeModel
                    }
                }
                
                if case .images(let imagesIncludeModel) = item {
                    if let bannerPivots = data?.relationships?.banners?.meta?.pivots {
                        let bannersID = bannerPivots.filter { $0.subCategory == categoryKey }.map(\.id!)
                        if bannersID.contains(imagesIncludeModel.id!) {
                            imagesIncludedModel.append(imagesIncludeModel)
                        }
                    }
                }
            }
        }
    
        return (categoryIncludedModel: categoryIncludedModel, productsIncludedModel: productsIncludedModel, imagesIncludedModel: imagesIncludedModel)
    }
    
    func allProductsAttributeFor(categoryID: String) -> [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>] {
        var productsIncludedModel = [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]()
        included?.forEach({ item in
            if case .products(let productIncludeModel) = item {
                productsIncludedModel.append(productIncludeModel)
            }

        })
        
        return productsIncludedModel
    }
    
    var allCategoriesID: [String] {
        var items = [String]()
        let defaultsCategories = ProductSortType.allCases.map(\.rawValue)
        items.append(contentsOf: defaultsCategories)
        if let childrenID = data?.relationships?.children?.data?.map(\.id!) {
            items.append(contentsOf: childrenID)
        }
        
        return items
    }
    
    var includedCategoriesModel: [IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>] {
        var includedCategoriesModel = [IncludedTypeModel<CategoryAttributeModel,IncludedCategoryProductDataModel>]()

        included?.forEach({ item in
            if case .categories(let categoryIncludeModel) = item {
                includedCategoriesModel.append(categoryIncludeModel)
            }
        })
        
        return includedCategoriesModel
    }

    var hasChild: Bool {
        if let children = data?.relationships?.children?.data {
            if children.isEmpty == true {
                return false
            }
        }
        
        return true
    }
}

extension Array where Element == BannerPivotModel {
    func metaBannerBy(BannerID: String) -> BannerPivotModel? {
        if let bannerPivotModel = first(where: { item in
            item.id == BannerID
        }) {
            return bannerPivotModel
        }
        
        return nil
    }
}
