//
//  MovieBookViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 11/20/1400 AP.
//

import UIKit
import AVFAudio
import AVKit
import AVFoundation

class MovieBookTableViewController: BaseTableViewController {
    enum Section: Hashable {
        case main
    }
    
    private var dataSource: UITableViewDiffableDataSource<Section, SeasonFile>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, SeasonFile>()
    
    private var currentFileIndex: Int = 0
    private var multiDownloader: MultiFilesDownloader?
    private var product: ProductResponseModel {
        return data as! ProductResponseModel
    }
    public weak var delegate: ProductDetailCollectionViewControllerDelegate?
    let playerController = LandscapeAVPlayerController()

    var isPurchase: Bool {
        if let purchased = CustomerAuth.shared.loginResponseModel?.purchasedProductIds {
            if let productID = product.data?.id {
                if purchased.contains(productID) {
                    return true
                }
            }
        }
        
        return false
    }
    
    override func configUI() {
        super.configUI()
        playerController.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reviewTimeEnded(notification:)), name: .fileReviewTimeEnded, object: nil)
        // play first audio file
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) { [weak self] in
//            self?.playSeasonAt(index: 0)
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func updateUI() {
        super.updateUI()
        configureDataSource()
        createSnapshot()
    }

    @objc func reviewTimeEnded(notification: Notification) {
        if let productID = notification.userInfo?["productID"] as? String {
            // check if this product is that preview product
            if productID == product.data?.id {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func playSeasonAt(index: Int) {
        let filesCount = self.product.seasonFiles.count
        if (index >= 0) && (index <= filesCount-1) {
            let file = product.seasonFiles[index].file
            if let filePath = try? ProductDetailCollectionViewController.filePath(fileID: file.id!, originalExtension: file.attributes!.originalExtension) {
                self.startAnimateIndicator()
                DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                    guard let self = self else { return }
                    let mp3Path = URL(fileURLWithPath: filePath)
                    if let decryptedData = mp3Path.decryptedData {
                        try? decryptedData.write(to: mp3Path)
                    }
                    self.currentFileIndex = index
                    self.stopAnimateIndicator()
                    self.startPlayer(path: filePath)
                }
            } else {
                currentFileIndex = index
                download(season: product.seasonFiles[index], indexPath: IndexPath(item: index, section: 0))
            }
        }
    }
    
    func startPlayer(path: String) {
        // play video
        let videoURL = URL(fileURLWithPath: path)
        let player = AVPlayer.init(url: videoURL)
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
        }
    }
    
    func playNextOrBackwardFile(atIndex: Int) {
        let filesCount = self.product.seasonFiles.count
        let nextFileIndex = atIndex
        if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
            // go to the next file available + decrypt and playit
            let file = self.product.seasonFiles[nextFileIndex].file
            if let fileID = file.id, let originalExtension = file.attributes?.originalExtension, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                self.startAnimateIndicator()
                DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                    guard let self = self else { return }
                    let mp3Path = URL(fileURLWithPath: filePath)
                    if let decryptedData = mp3Path.decryptedData {
                        try? decryptedData.write(to: mp3Path)
                    }
                    self.currentFileIndex = nextFileIndex
                    self.stopAnimateIndicator()
                    self.startPlayer(path: filePath)
                }
            }
        }
    }
    
    func playNextOrBackwardFile(seasonFile: SeasonFile) {
        // go to the next file available + decrypt and playit
        let file = seasonFile.file
        if let fileID = file.id, let originalExtension = file.attributes?.originalExtension, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
            self.startAnimateIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                guard let self = self else { return }
                let mp3Path = URL(fileURLWithPath: filePath)
                if let decryptedData = mp3Path.decryptedData {
                    try? decryptedData.write(to: mp3Path)
                }
                self.stopAnimateIndicator()
                self.startPlayer(path: filePath)
            }
        }
    }
    
    func download(season: SeasonFile, indexPath: IndexPath) {
        guard isPurchase else {
            showAlerInScreen(body: "لطفا برای مشاهده فصل‌های بیشتر محصول را خریداری کنید")
            return
        }
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        let config: DownloadManagerConfiguration? = isPurchase ? nil: DownloadManagerConfiguration(isTemporaryFile: true)
        let vc = DownloadProgressViewController
            .instantiate()
        multiDownloader = nil
        multiDownloader = MultiFilesDownloader(product: product, masterfile: season.file, otherFiles: season.otherFiles, config: config)
        multiDownloader?.downloadFiles(completion: { [weak self] (percent,status) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.downloadProgress(percent: percent, status: status)
                if status == .finished {
                    // finished file
                    self.multiDownloader = nil
                    DispatchQueue.main.async {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? MovieBookTableViewCell {
                            cell.button.setImage(UIImage(systemName: "trash"), for: .normal)
                        }
                    }
                    self.playNextOrBackwardFile(seasonFile: season)
                } else {
                    // open dowloader vc file
                    if status == .started {
                        vc.completionHandler = { [weak self] finished in
                            if finished {
                                // DownloadProgressViewController is dismissed auto by finshed download..
                            } else {
                                // canceled by user
                                self?.multiDownloader?.cancelDownloadFiles()
                                self?.multiDownloader = nil
                            }
                        }
                        
                        self.delegate = vc
                        self.present(vc)
                    }
                }
            }
        })
    }
}

extension MovieBookTableViewController: AVPlayerViewControllerDelegate {
    @objc func playerDidFinishPlaying() {
        print("playerDidFinishPlaying")
        self.playerController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.playSeasonAt(index: self.currentFileIndex+1)
        }
    }
}

extension MovieBookTableViewController: MovieBookTableViewCellDelegate {
    func deleteButtonTapped(cell: MovieBookTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let itemIdentifier = snapshot.itemIdentifiers[indexPath.item]
            if let fileID = itemIdentifier.file.id, let originalExtension = itemIdentifier.file.attributes?.originalExtension, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                let content = AlertContent(title: .delete, subject: "حذف فایل", description: "آیا میخواهید این فایل را از حافظه حذف کنید؟")
                let alertVC = AlertContentViewController
                    .instantiate()
                    .alert(content)
                
                alertVC.yesButtonTappedHandler = { [weak self] in

                    ProductDetailCollectionViewController.deleteFile(path: filePath)
                    if let cell = self?.tableView.cellForRow(at: indexPath) as? MovieBookTableViewCell {
                        cell.button.setImage(UIImage(systemName: "icloud.and.arrow.down"), for: .normal)
                    }
                }
                self.present(alertVC)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playSeasonAt(index: indexPath.item)
    }
    
    private func configureDataSource() {
        dataSource = .init(tableView: tableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MovieBookTableViewCell
            cell.delegate = self
            cell.titleLabel?.text = itemIdentifier.file.attributes?.name
            if let fileID = itemIdentifier.file.id, let originalExtension = itemIdentifier.file.attributes?.originalExtension, let _ = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                cell.button.setImage(UIImage(systemName: "trash"), for: .normal)
            } else {
                cell.button.setImage(UIImage(systemName: "icloud.and.arrow.down"), for: .normal)
            }
            
            return cell
        })
    }
    
    func createSnapshot() {
        let SeasonFiles = self.product.seasonFiles
        snapshot.appendSections([.main])
        snapshot.appendItems(SeasonFiles, toSection: .main)
        dataSource.apply(snapshot)
    }
}

protocol MovieBookTableViewCellDelegate: AnyObject {
    func deleteButtonTapped(cell: MovieBookTableViewCell)
}

class MovieBookTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    weak var delegate:MovieBookTableViewCellDelegate?
    
    @IBAction func deleteButtonTapped() {
        delegate?.deleteButtonTapped(cell: self)
    }
}
