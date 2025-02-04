//
//  ProductCommentCollectionViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/7/1400 AP.
//

import UIKit
protocol ProductCommentCollectionViewCellDelegate: AnyObject {
    func commentlikeButtonTapped(cell: ProductCommentCollectionViewCell)
    func commentDislikeButtonTapped(cell: ProductCommentCollectionViewCell)
}

class ProductCommentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var disLikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var disLikeLabel: UILabel!

    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: ProductCommentCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func udpateTheme(store: Bool) {
        if store {
            likeButton.setTitleColor(storeThemColor, for: .normal)
            disLikeButton.setTitleColor(storeThemColor, for: .normal)
            likeButton.tintColor = storeThemColor
            disLikeLabel.tintColor = storeThemColor
        }
    }
    
    func updateCell(score: ScoreAttributeModel) {
        rateControl.rating = Int(score.rank)
        likeLabel.text = "\(score.likesCount)"
        disLikeLabel.text = "\(score.dislikesCount)"

        if let url = score.userImageURL {
            profileImageView.loadImage(from: url)
        }
        nameLabel.text = score.userName
        dateLabel.text = score.dateTime.to(date: "yyyy/MM/dd")
        descriptionLabel.text = score.comment
    }

    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.commentlikeButtonTapped(cell: self)
    }
    
    @IBAction func disLikeButtonTapped(_ sender: Any) {
        delegate?.commentDislikeButtonTapped(cell: self)
    }
}
