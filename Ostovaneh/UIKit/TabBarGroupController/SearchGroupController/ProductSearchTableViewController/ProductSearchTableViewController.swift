//
//  ProductSearchTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/1/1400 AP.
//

import UIKit
import RestfulAPI

class ProductSearchTableViewController: BaseTableViewController {
    enum Section: Hashable {
        case main
    }
    
    @IBOutlet weak var countLabel: UILabel!
    
    private let searchController = UISearchController()
    private var dataSource: UITableViewDiffableDataSource<Section, IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func configUI() {
        super.configUI()
        // custom background color
        tableView.backgroundColor = .systemBackground
        // searchController
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.searchBar.setValue("بستن", forKey: "cancelButtonText")
        searchController.searchBar.placeholder = ""
        searchController.searchBar[keyPath: \.searchTextField].textAlignment = .right
        searchController.searchBar[keyPath: \.searchTextField].font = UIFont.iranSans(.medium, size: 14)
        let attributes:[NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.label,
            .font: UIFont.iranSans(.bold, size: 14)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        // dataSource and register cells
        register(tableView, with: ProductListTableViewCell.self)
        configureDataSource()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) { [weak self] in
//            self?.searchController.isActive = true
//        }
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
    
    private func createSnapshot(items: [IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>]) -> NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ProductAttributeModel,ProductRelationshipModel>>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        if items.isEmpty {
            countLabel.text = ""
        } else {
            countLabel.text = "تعداد محصولات: \(items.count)"
        }
        
        return snapshot
    }
}

extension ProductSearchTableViewController {
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

extension ProductSearchTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        // observer for fetch data aftar delay 1 second.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchMatchingItems), object: nil)
        perform(#selector(fetchMatchingItems), with: nil, afterDelay: 1)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadSnapshot(items: [])
    }
    
    private func fetchResult(searchTitle: String) {
        guard searchTitle.count > 1 else {
            reloadSnapshot(items: [])
            return
        }
        // send req to server and show the response into tableView
        let network = RestfulAPI<EMPTYMODEL,SearchResponseModel>.init(path: "/v1/search/\(searchTitle)")
        
        handleRequestByUI(network, animated: true) { [unowned self] result in
            if let result = result {
                reloadSnapshot(items: result.productsIncludedModel)
            }
        }
    }
    
    @objc private func fetchMatchingItems() {
        // search word if not empty
        if let searchTerm = searchController.searchBar.text, !searchTerm.isEmpty {
            // fetch from server and reload snapshot
            fetchResult(searchTitle: searchTerm)
            return
        }
        
        reloadSnapshot(items: [])
    }
}
