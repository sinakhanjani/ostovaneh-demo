//
//  RequestExtension.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/6/1400 AP.
//

import Foundation
import RestfulAPI
import UIKit

extension ProductDetailCollectionViewController {
    internal func postOrdersRequest(productID: String) {
        let userModel = ParentDataTypeModel<EMPTYHASHABLEMODEL,DataTypeModel>.init(meta: nil, data: DataTypeModel.init(id: CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.id, type: "users"), errors: nil)
        let body = OrderResponseModel(data: IncludedTypeModel<OrderAttributeModel,OrderRelationshipModel>.init(id: nil, type: "orders", attributes: OrderAttributeModel.init(status: "new", rand: nil, name: nil, basePrice: nil, basePriced: nil, discountPrice: nil, discountPriced: nil, finalPrice: nil, finalPriced: nil, productsCount: nil, currency: "toman"), relationships: OrderRelationshipModel.init(products: OrderRelationshipModel.ProductRelationshipModel.init(data: [DataTypeModel.init(id: productID, type: "products")]), user: userModel)), included: nil, errors: nil)
        
        let network = RestfulAPI<OrderResponseModel,OrderResponseModel>.init(path: "/v1/orders")
            .with(auth: .user)
            .with(queries: ["include":["products"].includes()])
            .with(method: .POST)
            .with(body: body)

        handleRequestByUI(network, animated: true) { results in
            CustomerAuth.shared.currentOrderModel = results
            // alert product added
        }
    }
    
    internal func patchOrdersRequest(productID: String) {
        guard let orderID = CustomerAuth.shared.currentOrderModel?.data?.id else { return }
        guard let body = CustomerAuth.shared.currentOrderModel else {
            return
        }
        
        var sendBody = body
        sendBody.included = nil

        if let basketProducts = body.data?.relationships?.products?.data {
            if basketProducts.contains(DataTypeModel.init(id: productID, type: "products")) {
                // for remove product
                sendBody.data!.relationships!.products!.removeProductFromList(productID: productID)
            } else {
                let product = IncludedTypeModel<ProductAttributeModel,OrderRelationshipModel.ProductRelationshipModel>.init(id: productID, type: "products", attributes: nil, relationships: nil)
                // for add product
                sendBody.data?.relationships?.products?.addProductToList(product: product)
            }
        }
        
        let network = RestfulAPI<OrderResponseModel,OrderResponseModel>.init(path: "/v1/orders/\(orderID)")
            .with(auth: .user)
            .with(queries: ["include":["products"].includes()])
            .with(method: .PATCH)
            .with(body: sendBody)
        
        handleRequestByUI(network, animated: true) {results in
            CustomerAuth.shared.currentOrderModel = results
        }
    }
    
    public func OrdersRequest(productID: String) {
        if CustomerAuth.shared.currentOrderModel?.data?.id == nil {
            postOrdersRequest(productID: productID)
        } else {
            patchOrdersRequest(productID: productID)
        }
    }
    
    public func fetchProductRequest(productID: String) {
        let network = RestfulAPI<EMPTYMODEL,ProductResponseModel>.init(path: "/v1/products/\(productID)")
            .with(queries: ["include":["images","files","translators","authors","publisher","scores","language","teachers","readers","narrators","directors","compilers","collectors","categories"].includes()])

        handleRequestByUI(network, animated: true) { [weak self] results in
            guard let self = self else { return }
            if let results = results {
                self.reloadSnapshot(item: results)
                self.title = results.data?.attributes?.name
                if !results.productCategories.isEmpty { // && self.parentCatID == ""
                    self.fetchSimularProductsRequest(catID: results.productCategories[0].id!)
                }
            }
        }
    }
    
    public func fetchHeaderProductsRequest(productHeader: ProductHeader) {
        let network = RestfulAPI<EMPTYMODEL,SimularProductModel>.init(path: "/v1/products")
            .with(queries: ["filter[\(productHeader.key)]":productHeader.id])

        handleRequestByUI(network, animated: true) { [weak self] results in
            if let items = results?.productsIncludedModel {
                self?.show(ProductListTableViewController
                            .instantiate()
                            .with(passing: items), sender: nil)
            }
        }
    }
    
    public func fetchSimularProductsRequest(catID: String) {
        let network = RestfulAPI<EMPTYMODEL,SimularProductModel>.init(path: "/v1/products")
            .with(queries: ["page[limit]":"10",
                            "filter[status]":"published",
                            "filter[categories]":catID])

        handleRequestByUI(network, animated: true) { [weak self] results in
            guard let self = self else { return }
            if let results = results {
                self.simularProducts = results.productsIncludedModel
                let section: ProductDetailCollectionViewController.Section = .simular(results.productsIncludedModel)
                let items: [ProductItemModel] = results.productsIncludedModel.prefix(5).map({ .product($0) })
                self.snapshot.appendSections([section])
                self.snapshot.appendItems(items, toSection: section)
                self.dataSource.apply(self.snapshot)
            }
        }
    }
    
    public func likeOrDisLikeRequest(scoreID: String, isLike: Int, result: @escaping (_ count: Int) -> Void) {
        let network = RestfulAPI<EMPTYMODEL,Data>.init(path: "/v1/score_like_dislike")
            .with(auth: .user)
            .with(method: .POST)
            .with(parameters: ["score_id":scoreID,"liked":"\(isLike)"])
        
        handleRequestByUI(network, animated: true) { results in
            if let results = results, let str = String(data: results, encoding: .utf8), let no = Int(str) {
                result(no)
            }
        }
    }
}
