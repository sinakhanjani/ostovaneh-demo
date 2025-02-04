//
//  ReplyCommentTableViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/9/1400 AP.
//

import UIKit
import RestfulAPI

class ReplyCommentTableViewController: BaseStoreViewController {
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    enum Section: Hashable {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section,IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>>()
    
    var productID: String?
    
    override func configUI() {
        super.configUI()
        register(tableView, with: ReplyCommentTableViewCell.self)
        configureDataSource()
        if let score = data as? IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL> {
            fetchData(scoreID: score.id!)
        }
        
        view.bindToKeyboard()
    }
    
    private func reloadSnapshot(items: [IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>]) {
        snapshot = createSnapshot(items: items)
        dataSource.apply(snapshot)
    }
    
    func fetchData(scoreID: String) {
        let network = RestfulAPI<EMPTYMODEL,ParentDataTypeModel<EMPTYHASHABLEMODEL,[IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>]>>.init(path: "/v1/scores/\(scoreID)/score-replies")
            .with(auth: .user)
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            guard let self = self else { return }
            if var items = results?.data, let score = self.data as? IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL> {
                items.insert(score, at: 0)
                self.reloadSnapshot(items: items)
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ReplyCommentTableViewCell.identifier, for: indexPath) as! ReplyCommentTableViewCell
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
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard !commentTextField.text!.isEmpty else {
            showAlerInScreen(body: "لطفا متن پیام را وارد کنید")
            return
        }
        guard let score = data as? IncludedTypeModel<ScoreAttributeModel,EMPTYHASHABLEMODEL>, let productID = productID else {
            return
        }
        
        let body = ParentDataTypeModel<EMPTYHASHABLEMODEL,IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>>.init(meta: nil, data: IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>.init(id: nil, type: "scores", attributes: CommentAttributeModel.init(comment: commentTextField.text!, rank: 0), relationships: CommentRelationshipModel.init(product: ParentDataTypeModel<EMPTYHASHABLEMODEL, DataTypeModel>.init(meta: nil, data: DataTypeModel.init(id: productID, type: "products"), errors: nil), parent: ParentDataTypeModel<EMPTYHASHABLEMODEL,DataTypeModel>.init(meta: nil, data: DataTypeModel.init(id: score.id!, type: "scores"), errors: nil))), errors: nil)
        typealias SendAndGetModel = ParentDataTypeModel<EMPTYHASHABLEMODEL,IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>>
        let network = RestfulAPI<SendAndGetModel,SendAndGetModel>.init(path: "/v1/scores")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            self?.commentTextField.text = ""
            self?.view.endEditing(true)
//            let alertContent = AlertContent(title: .none, subject: "", description: "سپاسگزاریم\nنظر شما ثبت شد و پس از تایید نمایش داده میشود.")
//            self?.present(WarningContentViewController
//                            .instantiate()
//                            .alert(alertContent))
            self?.fetchData(scoreID: score.id!)

            if let results = results {
                if let error = results.errors?[0], let detail = error.detail {
                    self?.showAlerInScreen(body: detail)
                    return
                }
            }
        }
    }
}


extension ReplyCommentTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
