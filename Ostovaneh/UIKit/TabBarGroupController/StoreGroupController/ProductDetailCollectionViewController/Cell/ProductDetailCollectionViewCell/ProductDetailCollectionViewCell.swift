//
//  ProductDetailCollectionViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/7/1400 AP.
//

import UIKit

class ProductDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateCell(item: ProductDetail) {
        titleLabel.text = item.title
        valueLabel.text = item.value
    }
}
