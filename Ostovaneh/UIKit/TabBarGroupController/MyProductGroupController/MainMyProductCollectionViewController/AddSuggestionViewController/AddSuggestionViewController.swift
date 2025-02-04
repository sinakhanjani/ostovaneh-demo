//
//  AddSuggestionViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/19/1400 AP.
//

import UIKit
import RestfulAPI

class AddSuggestionViewController: BaseTableViewController {

    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var suggestTextField: UITextField!

    override func configUI() {
        super.configUI()
    }
    
    @IBAction func agreeButtonTapped(_ sender: Any) {
        guard !suggestTextField.text!.isEmpty else {
            showAlerInScreen(body: "لطفا نظرتان را بنویسید و یک امتیاز برای آن انتخاب نمایید")
            return
        }
        guard let productID = data as? String else { return }
        let comment = suggestTextField.text!
        let body = ParentDataTypeModel<EMPTYHASHABLEMODEL,IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>>.init(meta: nil, data: IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>.init(id: nil, type: "scores", attributes: CommentAttributeModel.init(comment: comment, rank: Double(rateControl.rating)), relationships: CommentRelationshipModel.init(product: ParentDataTypeModel<EMPTYHASHABLEMODEL, DataTypeModel>.init(meta: nil, data: DataTypeModel.init(id: productID, type: "products"), errors: nil), parent: nil)), errors: nil)
        typealias SendAndGetModel = ParentDataTypeModel<EMPTYHASHABLEMODEL,IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>>
        let network = RestfulAPI<SendAndGetModel,SendAndGetModel>.init(path: "/v1/scores")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            if let results = results {
                if let error = results.errors?[0], let detail = error.detail {
                    self?.showAlerInScreen(body: detail)
                    return
                }
                let alertContent = AlertContent(title: .none, subject: "", description: "سپاسگزاریم\nنظر شما ثبت شد و پس از تایید نمایش داده میشود.")
                let vc = WarningContentViewController
                    .instantiate()
                    .alert(alertContent)
                vc.yesButtonTappedHandler = { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                self?.present(vc)
            }
        }
    }
}
