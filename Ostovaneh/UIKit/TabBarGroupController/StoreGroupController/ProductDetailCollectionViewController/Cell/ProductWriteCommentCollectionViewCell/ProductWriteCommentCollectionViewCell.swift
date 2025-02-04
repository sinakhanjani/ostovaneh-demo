//
//  ProductWriteCommentCollectionViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/8/1400 AP.
//

import UIKit

protocol ProductWriteCommentCollectionViewCellDelegate: AnyObject {
    func addCommentButtonTapped(rate: Int, comment: String)
}

class ProductWriteCommentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var commentTextFiel: UITextField!
    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var agreeButton: UIButton!

    weak var delegate: ProductWriteCommentCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateTheme(store: Bool) {
        if store {
            rateControl.tintColor = storeThemColor
            agreeButton.backgroundColor = storeThemColor
        }
    }

    @IBAction func agreeButtonTapped(_ sender: Any) {
        delegate?.addCommentButtonTapped(rate: rateControl.rating, comment: commentTextFiel.text!)
    }
}
