//
//  CategoryTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/1/1400 AP.
//

import UIKit
import RestfulAPI

class CategoryTableViewController: BaseTableViewController {
    enum Section: Hashable {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section,CategoryResponseModelElement>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, CategoryResponseModelElement>()
    
    override func configUI() {
        super.configUI()
        configureDataSource()
    }
    
    override func updateUI() {
        super.updateUI()
        if let categoryResponseModel = data as? CategoryResponseModel {
            reloadSnapshot(items: categoryResponseModel)
        } else {
            fetchData()
        }
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
        let network = RestfulAPI<EMPTYMODEL,CategoryResponseModel>.init(path: "/v1/all_categories")
        
        handleRequestByUI(network, animated: true) { [weak self] result in
            if let result = result, !result.isEmpty {
                self?.reloadSnapshot(items: result[0].children)
            }
        }
    }
    
    private func reloadSnapshot(items: CategoryResponseModel) {
        snapshot = createSnapshot(items: items)
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            
            if #available(iOS 14.0, *) {
                var content = cell.defaultContentConfiguration()
                content.textProperties.font = UIFont.iranSans(.medium, size: 17)
                content.text = item.name
                cell.contentConfiguration = content
            } else {
                // Fallback on earlier versions
                cell.textLabel?.text = item.name
            }
            
            return cell
        })
    }
    
    private func createSnapshot(items: CategoryResponseModel) -> NSDiffableDataSourceSnapshot<Section,CategoryResponseModelElement> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,CategoryResponseModelElement>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
}

extension CategoryTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = snapshot.itemIdentifiers[indexPath.item]
        
        if item.children.isEmpty {
            show(ProductListTableViewController
                    .instantiate()
                    .with(passing: item.id),
                 sender: nil)
        } else {
            show(CategoryTableViewController
                    .instantiate()
                    .with(passing: item.children),
                 sender: nil)
        }
    }
}
