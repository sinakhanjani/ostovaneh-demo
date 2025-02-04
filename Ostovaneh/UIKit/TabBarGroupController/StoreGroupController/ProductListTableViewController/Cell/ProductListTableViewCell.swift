//
//  ProductListTableViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 8/1/1400 AP.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {

    @IBOutlet weak var topRedLineView: UIView!
    @IBOutlet weak var bottomRedLineView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var secendaryTitleLabel: UILabel!
    @IBOutlet weak var thirdTitleLabel: UILabel!
    
    @IBOutlet weak var tomanOffPriceLabel: UILabel!
    @IBOutlet weak var tomanPriceLabel: UILabel!
    
    @IBOutlet weak var dollarOffPriceLabel: UILabel!
    @IBOutlet weak var dollarPriceLabel: UILabel!
    
    @IBOutlet weak var rateControl: STRatingControl!
    @IBOutlet weak var rateFromToLabel: UILabel!
    @IBOutlet weak var averageRateLabel: UILabel!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(item: ProductAttributeModel) {
        titleLabel.text = item.name
        secendaryTitleLabel.text = item.authorsName
        thirdTitleLabel.text = item.translatorsName
        thumbnailImageView.loadImage(from: item.thumbnailImageURL)

        if let rialOldPrice = item.rialOldPrice {
            if rialOldPrice == 0 {
                topRedLineView.alpha = 0
                tomanOffPriceLabel.text = "رایگان"
            } else {
                topRedLineView.alpha = 1
                tomanOffPriceLabel.text = "\(rialOldPrice.toPriceFormatter) تومان"
            }
        }
        if let usdOldPrice = item.usdOldPrice {
            if usdOldPrice == 0 {
                bottomRedLineView.alpha = 0
                dollarOffPriceLabel.text = "رایگان"
            } else {
                bottomRedLineView.alpha = 1
                dollarOffPriceLabel.text = "\(usdOldPrice.toCurrencyPriceFormatter) دلار"
            }
        }
        if let rialCurrentPrice = item.rialCurrentPrice {
            if rialCurrentPrice == 0 {
                tomanPriceLabel.text = "رایگان"
            } else {
                tomanPriceLabel.text = "\(rialCurrentPrice.toPriceFormatter) تومان"
            }
        }
        if let usdCurrentPrice = item.usdCurrentPrice {
            if usdCurrentPrice == 0 {
                dollarPriceLabel.text = "رایگان"
            } else {
                dollarPriceLabel.text = "\(usdCurrentPrice.toCurrencyPriceFormatter) دلار"
            }
        }

        if let rank = item.rank, rank > 0 {
            averageRateLabel.alpha = 1
            rateControl.alpha = 1
            rateControl.rating = Int(rank)
            averageRateLabel.text = "\(rank.rounded(toPlaces: 1))"
        } else {
            averageRateLabel.alpha = 0
            rateControl.alpha = 1
        }
        if let scoreCount = item.scoresCount, scoreCount > 0 {
            rateFromToLabel.text = "از \(Int(scoreCount)) رای"
        } else {
            rateFromToLabel.text = "بدون امتیاز"
            rateControl.rating = 1
        }
    }
}
