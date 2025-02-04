//
//  UIImageViewExtention.swift
//  Master
//
//  Created by Sina khanjani on 12/11/1399 AP.
//

import UIKit

public let cache = NSCache<NSString, UIImage>()
private let queue = DispatchQueue.global(qos: .utility)

extension UIImageView {
    ///Cache Images in a UICollectionView Using NSCache in Swift 5
    func loadImage(from address: String?, encoded: Bool = false, forKey: String = "") {
        image = nil
        queue.async {
            guard let address = address else {
                return
            }
            guard let url = URL(string: address) else {
                return
            }
            
            if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async {
                    if encoded {
                        UserDefaults.standard.set(cachedImage.jpegData(compressionQuality:0.1)!, forKey: forKey)
                    }
                    self.image = cachedImage
                }
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    if encoded {
                        UserDefaults.standard.set(image.jpegData(compressionQuality:0.1)!, forKey: forKey)
                    }
                    cache.setObject(image, forKey: url.absoluteString as NSString)
                    self.image  = image
                }
            }
        }
    }
}
