//
//  MainStoreViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 7/30/1400 AP.
//

import UIKit
import RestfulAPI

class MainStoreViewController: BaseStoreViewController {
    
    @IBOutlet weak var topBannerImageView: UIImageView!
    @IBOutlet weak var bottomBannerImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }

    override func configUI() {
        super.configUI()
        topBannerImageView.image = UIImage.gifImageWithName("mainBannerGifFile")
    }

    override func updateUI() {
        super.updateUI()
        fetchData()
    }
    
    private func fetchData() {
        fetchCategoryData(catId: "1") { [unowned self] result in
            if let banners = result?.data?.attributes?.banners_string.toJSONObject(typeOf: [ImageModel].self) {
                if let lastBannerURL = banners.last?.url {
                    bottomBannerImageView.loadImage(from: lastBannerURL)
                }
            }
        }
    }
    
    @IBAction func categoriesButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        switch tag {
        case 65:
            storeThemColor = .OSTOrange
        case 66:
            storeThemColor = .OSTGreen
        case 67:
            storeThemColor = .OSTBlue
        default: break
        }
        
        show(StoreCollectionViewController
                .instantiate()
                .with(passing: String(sender.tag)),
             sender: nil)
    }
}

extension MainStoreViewController: FetchCategoryRequestInjection { }
