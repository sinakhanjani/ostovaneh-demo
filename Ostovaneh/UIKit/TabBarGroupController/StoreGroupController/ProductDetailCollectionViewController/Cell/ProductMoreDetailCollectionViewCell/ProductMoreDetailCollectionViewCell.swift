//
//  ProductMoreDetailCollectionViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 11/24/1400 AP.
//

import UIKit

class ProductMoreDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var moreDescriptionButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!

    weak var delegate: ProductInfoCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateCell(item: ProductResponseModel) {
        if let productAttribute = item.data?.attributes {
            if let line = item.line {
                descriptionLabel.numberOfLines = line
                if line == 0 {
                    moreDescriptionButton.setTitle("کمتر", for: .normal)
                } else {
                    moreDescriptionButton.setTitle("بیشتر", for: .normal)
                }
            }
            
            descriptionLabel.text = productAttribute.body
        }
    }
    
    @IBAction func moreDescriptionButtonTapped(_ sender: Any) {
        delegate?.moreDescriptionButtonTapped(button: sender as! UIButton)
    }
}
