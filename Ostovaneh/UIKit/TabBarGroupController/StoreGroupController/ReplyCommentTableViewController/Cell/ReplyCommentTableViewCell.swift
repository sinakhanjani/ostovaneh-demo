//
//  ReplyCommentTableViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/9/1400 AP.
//

import UIKit

class ReplyCommentTableViewCell: UITableViewCell {
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
        if let url = score.userImageURL {
            profileImageView.loadImage(from: url)
        }
        nameLabel.text = score.userName
        dateLabel.text = score.dateTime.to(date: "yyyy/MM/dd")
        descriptionLabel.text = score.comment
    }
}
