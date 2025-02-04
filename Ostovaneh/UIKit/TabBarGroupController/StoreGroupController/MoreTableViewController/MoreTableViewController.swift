//
//  MoreTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/7/1400 AP.
//

import UIKit

struct MoreModel: Hashable, Codable {
    let id: String
    let key: String?
    let faKey: String?
    var name: String
    var imageName: String? = nil
}

protocol MoreTableViewControllerDelegate: AnyObject {
    func headerSelected(_ more: MoreModel)
}

class MoreTableViewController: BaseStoreTableViewController {
    enum Section: Hashable {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section, MoreModel>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, MoreModel>()
    
    weak var delegate: MoreTableViewControllerDelegate?
    var currentModel: MoreModel?
    
    override func configUI() {
        super.configUI()
        configureDataSource()
    }
    
    override func updateUI() {
        super.updateUI()
        if let headers = data as? [ProductHeader] {
            snapshot.appendSections([.main])
            let items = headers.map({ MoreModel(id: $0.id, key: $0.key, faKey: $0.faKey, name: $0.name) })
            snapshot.appendItems(items, toSection: .main)
            dataSource.apply(snapshot)
        }
        
        if let productCategories = data as? [IncludedTypeModel<CategoryAttributeModel, EMPTYHASHABLEMODEL>] {
            snapshot.appendSections([.main])
            let items = productCategories.map({ MoreModel(id: $0.id!, key: nil, faKey: nil, name: $0.attributes!.name!) })
            snapshot.appendItems(items, toSection: .main)
            dataSource.apply(snapshot)
        }
        
        if let mores = data as? [MoreModel] {

            snapshot.appendSections([.main])
            snapshot.appendItems(mores, toSection: .main)
            dataSource.apply(snapshot)
        }
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            guard let self = self else { return nil }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            if #available(iOS 14.0, *) {
                var content = cell.defaultContentConfiguration()
                content.textProperties.font = UIFont.iranSans(.black, size: 17)
                content.secondaryTextProperties.font = UIFont.iranSans(.medium, size: 17)
                content.text = itemIdentifier.faKey
                content.secondaryText = itemIdentifier.name
                if let imageName = itemIdentifier.imageName {
                    content.image = UIImage(systemName: imageName)
                }
                if let currentModel = self.currentModel {
                    if currentModel.id == itemIdentifier.id {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
                cell.contentConfiguration = content
            } else {
                // Fallback on earlier versions
                cell.textLabel?.text = itemIdentifier.name
                cell.detailTextLabel?.text = itemIdentifier.faKey
                if let imageName = itemIdentifier.imageName {
                    cell.imageView?.image = UIImage(systemName: imageName)
                }
                if let currentModel = self.currentModel {
                    if currentModel.id == itemIdentifier.id {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
            }
            
            return cell
        })
    }
}

extension MoreTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = snapshot.itemIdentifiers[indexPath.item]
        dismiss(animated: true) { [weak self] in
            self?.delegate?.headerSelected(item)
        }
    }
}
