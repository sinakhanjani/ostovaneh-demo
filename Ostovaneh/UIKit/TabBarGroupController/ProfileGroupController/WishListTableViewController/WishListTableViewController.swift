//
//  WishListTableViewController.swift
//  Ostovaneh
//
//  Created by Hossein Hajimirza on 10/27/21.
//

import UIKit
import RestfulAPI

class WishListTableViewController: BaseTableViewController {
    enum Section: Hashable {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section, IncludedTypeModel<ProductAttributeModel, ProductRelationshipModel>>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, IncludedTypeModel<ProductAttributeModel, ProductRelationshipModel>>()
    
    override func configUI() {
        super.configUI()
        tableView.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        register(tableView, with: ProductListTableViewCell.self)
        configureDataSource()
    }
    
    override func updateUI() {
        super.updateUI()
        fetchData()
    }
    
    override func reachabilityStatusChanges(_ notification: Notification) {
        super.reachabilityStatusChanges(notification)
        if case .online(_) = connetctionStatus {
            tableView.backgroundView = nil
            updateUI()
        } else {
            tableView.backgroundView = BadConnectionView()
            reloadSnapshot(items: [])
        }
    }
    
    private func fetchData() {
        guard let userID = CustomerAuth.shared.loginResponseModel?.userResponseModel?.data?.id else {
            return
        }
        let network = RestfulAPI<EMPTYMODEL,FavoriteResponseModel>.init(path: "/v1/users/\(userID)/saved-products")
            .with(auth: .user)
            
        handleRequestByUI(network, animated: true) { [weak self] result in
            if let data = result?.data {
                self?.reloadSnapshot(items: data)
            }
        }
    }
    
    private func reloadSnapshot(items: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]) {
        snapshot = createSnapshot(items: items)
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTableViewCell.identifier) as! ProductListTableViewCell
            
            if let productAttribute = itemIdentifier.attributes {
                cell.updateCell(item: productAttribute)
            }
            
            return cell
        })
    }
    
    private func createSnapshot(items: [IncludedTypeModel<ProductAttributeModel, ProductRelationshipModel>]) -> NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel, ProductRelationshipModel>> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel, ProductRelationshipModel>>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
}

extension WishListTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        show(ProductDetailCollectionViewController
                .instantiate()
                .with(passing: snapshot.itemIdentifiers[indexPath.item].id!),
             sender: nil)
    }
}
// MARK: - SearchResponseModel
struct FavoriteResponseModel: Codable {
    let data: [IncludedTypeModel<ProductAttributeModel, ProductRelationshipModel>]?
}

