//
//  DownloadProgressViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/28/1400 AP.
//

import UIKit

//protocol DownloadProgressViewController: AnyObject {
//
//}

class DownloadProgressViewController: UIViewController {
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var percent: Int = 0
    var completionHandler: ((_ finished: Bool) -> Void)?
    
    @IBAction func cancelButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.completionHandler?(false)
        }
    }
}

extension DownloadProgressViewController: ProductDetailCollectionViewControllerDelegate {
    func downloadProgress(percent: Int, status: DownloadStatus) {
        if isViewLoaded {
            progressView.setProgress(Float(percent)/100, animated: true)
            percentLabel.text = "\(percent)%"
            if status == .finished {
                dismiss(animated: false) { [weak self] in
                    self?.completionHandler?(true)
                }
            }
        }
    }
}
