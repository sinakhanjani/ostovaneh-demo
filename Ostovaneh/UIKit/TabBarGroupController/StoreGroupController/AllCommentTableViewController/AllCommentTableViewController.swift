//
//  AllCommentTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/9/1400 AP.
//

import UIKit

class AllCommentTableViewController: BaseStoreTableViewController {
    
    enum Section: Hashable {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section,IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>>()
    
    var productID: String?
    
    override func configUI() {
        super.configUI()
        register(tableView, with: AllCommentTableViewCell.self)
        configureDataSource()
        if let items = data as? [IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>] {
            reloadSnapshot(items: items)
        }
    }
    
    override func updateUI() {
        super.updateUI()
    }
    
    private func reloadSnapshot(items: [IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>]) {
        snapshot = createSnapshot(items: items)
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: AllCommentTableViewCell.identifier, for: indexPath) as! AllCommentTableViewCell
            if self?.tabBarController?.selectedIndex == 2 {

            }
            cell.updateCell(score: item.attributes!)
            
            return cell
        })
    }
    
    private func createSnapshot(items: [IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>]) -> NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>> {
        var snapshot = NSDiffableDataSourceSnapshot<Section,IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        return snapshot
    }
}

extension AllCommentTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        
        let item = snapshot.itemIdentifiers[indexPath.item]
        let vc = ReplyCommentTableViewController
            .instantiate()
            .with(passing: item)
        vc.productID = productID
        
        show(vc, sender: nil)
    }
}
