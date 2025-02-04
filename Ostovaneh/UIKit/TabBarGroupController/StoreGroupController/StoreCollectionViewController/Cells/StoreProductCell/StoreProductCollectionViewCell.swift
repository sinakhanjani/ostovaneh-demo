//
//  StoreProductCollectionViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/30/1400 AP.
//

import UIKit

class StoreProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var rateImageView: UIImageView!
    @IBOutlet weak var redLineView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var offPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(item: ProductAttributeModel) {
        titleLabel.text = item.name
        imageView.loadImage(from: item.thumbnailImageURL)

        if let rialOldPrice = item.rialOldPrice {
            if rialOldPrice == 0 {
                redLineView.alpha = 0
                offPriceLabel.text = "رایگان"
            } else {
                redLineView.alpha = 1
                offPriceLabel.text = "\(rialOldPrice.toPriceFormatter) تومان"
            }
        }
        if let rialCurrentPrice = item.rialCurrentPrice {
            if rialCurrentPrice == 0 {
                priceLabel.text = "رایگان"
            } else {
                priceLabel.text = "\(rialCurrentPrice.toPriceFormatter) ت"
            }
        }
        if let rank = item.rank, rank > 0 {
            rateImageView.alpha = 1
            rateLabel.alpha = 1
            rateLabel.text = "\(rank.rounded(toPlaces: 1))"
        } else {
            rateImageView.alpha = 0
            rateLabel.alpha = 1
            rateLabel.text = "" //when no rate
        }
    }
}
