//
//  ProductInfoCollectionViewCell.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/7/1400 AP.
//

import UIKit

protocol ProductInfoCollectionViewCellDelegate: AnyObject {
    func moreHeaderButtonTapped()
    func authorButtonTapped()
    func translatorButtonTapped()
    func shareButtonTapped()
    func giftButtonTapped()
    func oldVersionButtonTapped()
    func readBookButtonTapped(button: UIButton)
    func moreDescriptionButtonTapped(button: UIButton)
    func favoriteButtonTapped()
    func checkProductButtonTapped()
    func trashButtonTapped(button: UIButton)
}

class ProductInfoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var redLineView: UIView!
    @IBOutlet weak var redDollarLineView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var authorButton: UIButton!
    @IBOutlet weak var translatorButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var giftButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet weak var readBookButton: UIButton!
    @IBOutlet weak var oldVersionButton: UIButton!
    
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var checkProductButton: UIButton!
    
//    @IBOutlet weak var moreDescriptionButton: UIButton!

    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var oldPriceLabel: UILabel!
    
    @IBOutlet weak var oldDollarPriceLabel: UILabel!
    @IBOutlet weak var currentDollarPriceLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateControl: STRatingControl!
    
    @IBOutlet weak var fileTypeLabel: UILabel!
    @IBOutlet weak var fileTypeImageView: UIImageView!
    
//    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var trashButton: UIButton!
    
    
    weak var delegate: ProductInfoCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func trashButtonTapped(_ sender: UIButton) {
        delegate?.trashButtonTapped(button: sender)
    }

    @IBAction func moreButtonTapped(_ sender: Any) {
        delegate?.moreHeaderButtonTapped()
    }
    
    @IBAction func authorButtonTapped(_ sender: Any) {
        delegate?.authorButtonTapped()
    }
    
    @IBAction func translatorButtonTapped(_ sender: Any) {
        delegate?.translatorButtonTapped()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        delegate?.shareButtonTapped()
    }
    
    @IBAction func giftButtonTapped(_ sender: Any) {
        delegate?.giftButtonTapped()
    }
    
    @IBAction func oldVersionButtonTapped(_ sender: Any) {
        delegate?.oldVersionButtonTapped()
    }
    
    @IBAction func readBookButtonTapped(_ sender: Any) {
        delegate?.readBookButtonTapped(button: sender as! UIButton)
    }
    
    @IBAction func moreDescriptionButtonTapped(_ sender: Any) {
        delegate?.moreDescriptionButtonTapped(button: sender as! UIButton)
    }

    @IBAction func favoriteButtonTapped(_ sender: Any) {
        delegate?.favoriteButtonTapped()
    }
    
    @IBAction func checkProductButtonTapped(_ sender: Any) {
        delegate?.checkProductButtonTapped()
    }
    
    func enablePurchaseButton(_ isPurchase: Bool, _ isProductIntoBasket: Bool,_ isViewed: Bool) {
        checkProductButton.alpha = isPurchase ? 0:1
//        favoriteButton.alpha = isPurchase ? 0:1
        
        if CustomerAuth.shared.isLogin {
            if isPurchase {
                readBookButton.setTitle("مشاهده", for: .normal)
            } else if isProductIntoBasket {
                readBookButton.setTitle("موجود در سبد", for: .normal)
            } else {
                readBookButton.setTitle("افزودن به سبد", for: .normal)
            }
        } else {
            readBookButton.setTitle("افزودن به سبد", for: .normal)
        }
    }
    
    func updateCell(item: ProductResponseModel, activeThemeMode: Bool) {
        // theme
        if activeThemeMode {
            giftButton.tintColor = storeThemColor
            shareButton.tintColor = storeThemColor
            readBookButton.backgroundColor = storeThemColor
            oldVersionButton.backgroundColor = storeThemColor
            rateControl.tintColor = storeThemColor
            favoriteButton.backgroundColor = storeThemColor
            checkProductButton.backgroundColor = storeThemColor
        }
        // attribute
        if let forKey = item.data?.id, let savedImage = UserDefaults.standard.value(forKey: forKey) as? Data {
            coverImageView.image = UIImage(data: savedImage)
        } else {
            if let imageURL = item.data?.attributes?.thumbnailImageURL {
                coverImageView.loadImage(from: imageURL)
            }
        }
        if let productAttribute = item.data?.attributes {
            titleLabel.text = productAttribute.name
            if let author = productAttribute.authorsName, author != "" {
                authorButton.alpha = 1
                authorButton.setTitle(author, for: .normal)
                translatorButton.setTitle(author, for: .selected)
            } else {
                authorButton.alpha = 0
            }
            if let translator = productAttribute.translatorsName, translator != "" {
                translatorButton.alpha = 1
                translatorButton.setTitle(translator, for: .normal)
                translatorButton.setTitle(translator, for: .selected)
            } else {
                translatorButton.alpha = 0
            }
            if productAttribute.translatorsName != "" && productAttribute.authorsName != "" {
                moreButton.alpha = 1
            } else {
                moreButton.alpha = 0
            }
            // toman
            if let oldPrice = productAttribute.rialOldPrice {
                if oldPrice == 0 {
                    redLineView.alpha = 0
                } else {
                    oldPriceLabel.text = "\(oldPrice.toPriceFormatter) تومان"
                    redLineView.alpha = 1
                }
            }
            if let currentPrice = productAttribute.rialCurrentPrice {
                if currentPrice == 0 {
                    currentPriceLabel.text = "رایگان"
                } else {
                    currentPriceLabel.text = "\(currentPrice.toPriceFormatter) تومان"
                }
            }
            // dollar USD
            if let oldDollarPrice = productAttribute.usdOldPrice {
                if oldDollarPrice == 0 {
                    redDollarLineView.alpha = 0
                } else {
                    oldDollarPriceLabel.text = "\(oldDollarPrice.toCurrencyPriceFormatter) $"
                    redDollarLineView.alpha = 1
                }
            }
            if let currentUSDPrice = productAttribute.usdCurrentPrice {
                if currentUSDPrice == 0 {
                    currentDollarPriceLabel.text = "رایگان"
                    if let oldDollarPrice = productAttribute.usdOldPrice {
                        if oldDollarPrice == 0 && currentUSDPrice == 0 {
                            currentDollarPriceLabel.text = ""
                        }
                    }
                } else {
                    currentDollarPriceLabel.text = "\(currentUSDPrice.toCurrencyPriceFormatter) $"
                }
            }
            
            if let rate = productAttribute.rank {
                rateControl.rating = Int(rate)
            }
            if let scoresCount = productAttribute.scoresCount {
                if scoresCount == 0 {
                    rateLabel.text = "بدون امتیاز"
                    rateControl.alpha = 1
                    rateControl.rating = 1
                } else {
                    rateControl.alpha = 1
                    rateLabel.text = "از \(Int(scoresCount)) رای"
                }
            }
            
            fileTypeLabel.text = productAttribute.fileTypeEnum?.title ?? ""
            fileTypeImageView.image = productAttribute.fileTypeEnum?.icon
            
            if productAttribute.hasOtherVersions == "true" {
                oldVersionButton.isEnabled = true
            } else {
                oldVersionButton.isEnabled = false
            }
        }
    }
}
