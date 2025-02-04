//
//  AllCommentTableViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/9/1400 AP.
//

import UIKit

class AllCommentTableViewCell: UITableViewCell {
    @IBOutlet weak var disLikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var disLikeLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        commentCountLabel.text = "\(score.repliesCount)"
    }
}
