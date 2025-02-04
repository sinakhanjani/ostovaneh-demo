//
//  ProductListTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/1/1400 AP.
//

import UIKit
import RestfulAPI

class ProductListTableViewController: BaseStoreTableViewController {
    enum Section: Hashable {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section,IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>()
    
    public var productSortBy: ProductSortType?
    
    override func configUI() {
        super.configUI()
        navigationItem.largeTitleDisplayMode = .never
        // dataSource and register cells
        register(tableView, with: ProductListTableViewCell.self)
        configureDataSource()
    }
    
    override func updateUI() {
        super.updateUI()
        fetchData(productSortType: productSortBy)
    }
    
    override func reachabilityStatusChanges(_ notification: Notification) {
        super.reachabilityStatusChanges(notification)
        if case .online(_) = connetctionStatus {
            updateUI()
            tableView.backgroundView = nil
        } else {
            dataSource.apply(createSnapshot(items: []))
            tableView.backgroundView = BadConnectionView()
        }
    }
    
    private func fetchData(productSortType: ProductSortType? = nil, skip: Int = 0) {
        if let catID = data as? String {
            // configuration sort menu
            configurationRightBarButton()
            // fetch by catID
            fetchCategoryData(catId: catID, sortBy: productSortType, skip: skip) { [weak self] result in
                if let items = result?.allProductsAttributeFor(categoryID: catID) {
                    self?.reloadSnapshot(items: items)
                }
            }
            return
        }
        // fetch direct by products data item
        if let items = data as? [IncludedTypeModel<ProductAttributeModel, ProductRelationshipModel>] {
            reloadSnapshot(items: items)
        }
    }
    
    private func configurationRightBarButton() {
        func reloadSnapshotByChangeSort(type: ProductSortType) {
            snapshot.deleteItems(snapshot.itemIdentifiers)
            productSortBy = type
            fetchData(productSortType: type)
        }
        let sortByNewestAction = UIAction(title: ProductSortType.new.title, image: UIImage(systemName: "list.star"), handler: { _ in
            reloadSnapshotByChangeSort(type: .new)
        })
        let sortByFreeAction = UIAction(title: ProductSortType.free.title, image: UIImage(systemName: "list.dash"), handler: { _ in
            reloadSnapshotByChangeSort(type: .free)
        })
        let sortBySuggestionAction = UIAction(title: ProductSortType.offer.title, image: UIImage(systemName: "list.bullet"), handler: { _ in
            reloadSnapshotByChangeSort(type: .offer)
        })
        let sortByBestSellersAction = UIAction(title: ProductSortType.topsale.title, image: UIImage(systemName: "list.triangle"), handler: { _ in
            reloadSnapshotByChangeSort(type: .topsale)
        })

        let menu = UIMenu(options: .displayInline, children: [
            sortByNewestAction,
            sortByFreeAction,
            sortBySuggestionAction,
            sortByBestSellersAction
        ])
        
        if #available(iOS 14.0, *) {
            let sortBarButton = UIBarButtonItem(title: "", image: UIImage(systemName: "arrow.up.arrow.down"), primaryAction: nil, menu: menu)
            navigationItem.rightBarButtonItem = sortBarButton
        }
    }
    
    private func reloadSnapshot(items: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]) {
        snapshot = createSnapshot(items: items)
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTableViewCell.identifier) as! ProductListTableViewCell
            cell.updateCell(item: itemIdentifier.attributes!)
            
            return cell
        })
    }
    
    private func createSnapshot(items: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]) -> NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>()
        let oldItems = self.snapshot.itemIdentifiers
        let allItems = oldItems + items
        
        snapshot.appendSections([.main])
        snapshot.appendItems(allItems.uniqued(), toSection: .main)
        
        return snapshot
    }
}

extension ProductListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let itemIdentifiersCount = snapshot.itemIdentifiers.count
        if indexPath.item+1 == itemIdentifiersCount {
            fetchData(productSortType: productSortBy, skip: itemIdentifiersCount)
        }
    }
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        44
//    }
//    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: CGRect.zero)
//        
//        let titleLabel = UILabel()
//        titleLabel.font = UIFont.iranSans(.bold, size: 14)
//        titleLabel.textColor = UIColor.label
//        titleLabel.textAlignment = .right
//        titleLabel.text = "تعداد محصولات: \(self.snapshot.itemIdentifiers.count)"
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        headerView.addSubview(titleLabel)
//        
//        NSLayoutConstraint.activate([
//            // titleLabel constraint:
//            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
//            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
//            // descriptionLabel constraint:
//            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
//            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
//        ])
//                
//        return headerView
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let productID = snapshot.itemIdentifiers[indexPath.item].id {
            let vc = ProductDetailCollectionViewController
                .instantiate()
                .with(passing: productID)
            if let catID = data as? String {
                vc.parentCatID = catID
            }
            show(vc,
                 sender: nil)
        }
    }
}

extension ProductListTableViewController: FetchCategoryRequestInjection { }
