//
//  ProductDetailCollectionViewControllerExtention.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/6/1400 AP.
//

import Foundation
import UIKit
import RestfulAPI
import SwiftUI
import FolioReaderKit
import AVKit
import AVFoundation

protocol ProductDetailCollectionViewControllerDelegate: AnyObject {
    func downloadProgress(percent: Int, status: DownloadStatus)
}

extension ProductDetailCollectionViewController {
    var isProductIntoBasket: Bool {
        if let products = CustomerAuth.shared.currentOrderModel?.data?.relationships?.products?.data {
            if let productID = data as? String {
                if products.contains(DataTypeModel.init(id: productID, type: "products")) {
                    return true
                }
            }
        }
        
        return false
    }
    
    var isViewed: Bool {
        if let viewed = CustomerAuth.shared.loginResponseModel?.viewedProductIds {
            if let productID = data as? String {
                if viewed.contains(productID) {
                    return true
                }
            }
        }
        
        return false
    }
    
    var isPurchase: Bool {
        if let purchased = CustomerAuth.shared.loginResponseModel?.purchasedProductIds {
            if let productID = data as? String {
                if purchased.contains(productID) {
                    return true
                }
            }
        }
        // this happen in offline mode
        if let productID = data as? String {
            if let _ = ProductResponseModel.fetchRecordedProducts().first(where: { item in
                item.data?.id == productID
            }) {
                return true
            }
        }
        return false
    }
}

extension ProductDetailCollectionViewController: ProductInfoCollectionViewCellDelegate, MoreTableViewControllerDelegate, ProductCommentCollectionViewCellDelegate, ProductWriteCommentCollectionViewCellDelegate {
    func trashButtonTapped(button: UIButton) {
        if let productResponseModel = snapshot.itemIdentifiers.first {
            if case .info(let info) = productResponseModel {
                if let fileID = info.files.first?.id, let originalExtension = info.files.first?.attributes?.originalExtension, let _ = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                    let content = AlertContent(title: .delete, subject: "حذف فایل", description: "آیا میخواهید این فایل را از حافظه حذف کنید؟")
                    let alertVC = AlertContentViewController
                        .instantiate()
                        .alert(content)
                    
                    alertVC.yesButtonTappedHandler = {
                        ProductDetailCollectionViewController.deleteAllFiles(info: info)
                        ProductResponseModel.removeProduct(item: info)
                        button.alpha = 0
                    }
                    self.present(alertVC)
                }
            }
        }
    }
    
    func addCommentButtonTapped(rate: Int, comment: String) {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        guard isPurchase else {
            showAlerInScreen(body: "برای ثبت نظر میبایست این محصول را خریداری کرده باشید")
            return
        }
        guard !comment.isEmpty else {
            showAlerInScreen(body: "لطفا نظرتان را بنویسید و یک امتیاز برای آن انتخاب نمایید")
            return
        }
        guard let productID = data as? String else { return }
        
        let body = ParentDataTypeModel<EMPTYHASHABLEMODEL,IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>>.init(meta: nil, data: IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>.init(id: nil, type: "scores", attributes: CommentAttributeModel.init(comment: comment, rank: Double(rate)), relationships: CommentRelationshipModel.init(product: ParentDataTypeModel<EMPTYHASHABLEMODEL, DataTypeModel>.init(meta: nil, data: DataTypeModel.init(id: productID, type: "products"), errors: nil), parent: nil)), errors: nil)
        typealias SendAndGetModel = ParentDataTypeModel<EMPTYHASHABLEMODEL,IncludedTypeModel<CommentAttributeModel,CommentRelationshipModel>>
        let network = RestfulAPI<SendAndGetModel,SendAndGetModel>.init(path: "/v1/scores")
            .with(auth: .user)
            .with(method: .POST)
            .with(body: body)
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            if let results = results {
                if let error = results.errors?[0], let detail = error.detail {
                    self?.showAlerInScreen(body: detail)
                    return
                }
                self?.showAlerInScreen(body: "سپاسگزاریم\nنظر شما ثبت شد و پس از تایید نمایش داده میشود.")
            }
        }
    }
    
    func commentlikeButtonTapped(cell: ProductCommentCollectionViewCell) {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        if let indexPath = collectionView.indexPath(for: cell) {
            let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
            let itemsIdentifier = snapshot.itemIdentifiers(inSection: sectionIdentifier)
            let itemIdentifier = itemsIdentifier[indexPath.item]
            
            if case .comment(let comment) = itemIdentifier {
                likeOrDisLikeRequest(scoreID: comment.id!, isLike: 1, result: { count in
                    cell.likeLabel.text = "\(comment.attributes!.likesCount+1)"
                    //                    if comment.attributes!.isLikedByUser == "true" {
                    //                        cell.likeLabel.text = "\(comment.attributes!.likesCount+1)"
                    //                    } else {
                    //                        cell.likeLabel.text = "\(comment.attributes!.likesCount-1)"
                    //                    }
                })
            }
        }
    }
    
    func commentDislikeButtonTapped(cell: ProductCommentCollectionViewCell) {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        if let indexPath = collectionView.indexPath(for: cell) {
            let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
            let itemsIdentifier = snapshot.itemIdentifiers(inSection: sectionIdentifier)
            let itemIdentifier = itemsIdentifier[indexPath.item]
            
            if case .comment(let comment) = itemIdentifier {
                likeOrDisLikeRequest(scoreID: comment.id!, isLike: 0, result: { count in
                    cell.disLikeLabel.text = "\(count)"
                    cell.disLikeLabel.text = "\(comment.attributes!.dislikesCount+1)"
                    //                    if comment.attributes!.isDisLikedByUser == "true" {
                    //                        cell.disLikeLabel.text = "\(comment.attributes!.dislikesCount+1)"
                    //                    } else {
                    //                        cell.disLikeLabel.text = "\(comment.attributes!.dislikesCount-1)"
                    //                    }
                })
            }
        }
    }
    
    //MoreTableViewControllerDelegate
    func headerSelected(_ more: MoreModel) {
        // come from header product
        if more.key != nil {
            let header = ProductHeader(id: more.id, key: more.key!, faKey: more.faKey!, name: more.name)
            fetchHeaderProductsRequest(productHeader: header)
        }
        // come from categori product
        if more.key == nil {
            // more.id means categoryID
            show(ProductListTableViewController
                    .instantiate()
                    .with(passing: more.id), sender: nil)
        }
    }
    
    func moreHeaderButtonTapped() {
        let itemIdentifiers = snapshot.itemIdentifiers
        itemIdentifiers.forEach { itemIdentifier in
            if case .info(let productResponseModel) = itemIdentifier {
                let vc = MoreTableViewController
                    .instantiate()
                    .with(passing: productResponseModel.filterProductHeaders)
                vc.delegate = self
                
                present(vc)
            }
        }
    }
    
    func authorButtonTapped() {
        let itemIdentifiers = snapshot.itemIdentifiers
        itemIdentifiers.forEach { itemIdentifier in
            if case .info(let productResponseModel) = itemIdentifier {
                productResponseModel.filterProductHeaders.forEach { header in
                    if header.key == "authors" {
                        fetchHeaderProductsRequest(productHeader: header)
                        return
                    }
                }
            }
        }
    }
    
    func translatorButtonTapped() {
        let itemIdentifiers = snapshot.itemIdentifiers
        itemIdentifiers.forEach { itemIdentifier in
            if case .info(let productResponseModel) = itemIdentifier {
                productResponseModel.filterProductHeaders.forEach { header in
                    if header.key == "translators" {
                        fetchHeaderProductsRequest(productHeader: header)
                        return
                    }
                }
            }
        }
    }
    
    func shareButtonTapped() {
        let itemIdentifiers = snapshot.itemIdentifiers
        itemIdentifiers.forEach { itemIdentifier in
            if case .info(let productResponseModel) = itemIdentifier {
                if let url = productResponseModel.data?.attributes?.url {
                    let message = """
 سلام و عرض ادب من از دیدن این محصول در استوانه لذت بردم، پیشنهاد می کنم این محصول را در فروشگاه استوانه مشاهده فرمایید. پس روی لینک زیر کلیک کنید.
 \(url)
"""
                    let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                    present(vc)
                }
            }
        }
    }
    
    func giftButtonTapped() {
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        
        let itemIdentifiers = snapshot.itemIdentifiers
        itemIdentifiers.forEach { itemIdentifier in
            if case .info(let productResponseModel) = itemIdentifier {
                let vc = EnterGiftCodeTableViewController
                    .instantiate()
                    .with(passing: "fromGiftPhone")
                vc.productID = productResponseModel.data?.id
                
                present(vc)
                return
            }
        }
    }
    
    func oldVersionButtonTapped() {
        guard let productID = data as? String else {
            return
        }
        let network = RestfulAPI<EMPTYMODEL,SimularProductModel>.init(path: "/v1/products/\(productID)/other-versions")
            .with(auth: .user)
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            if let items = results?.productsIncludedModel {
                self?.show(ProductListTableViewController
                            .instantiate()
                            .with(passing: items), sender: nil)
            }
        }
        
    }
    
    func moreDescriptionButtonTapped(button: UIButton) {
        let itemIdentifiers = snapshot.itemIdentifiers
        
        itemIdentifiers.forEach { itemIdentifier in
            if case .moreDetail(let productResponseModel) = itemIdentifier {
                var x = productResponseModel
                let minLine = 3
                let maxLine = 0
                // change type of line
                x.line = (x.line == maxLine) ? minLine:maxLine
                reloadSnapshot(item: x)
                return
            }
        }
    }
    
    func favoriteButtonTapped() {
        guard let productID = data as? String else { return }
        let network = RestfulAPI<EMPTYMODEL,Data>.init(path: "/v1/users/save_product/\(productID)")
            .with(auth: .user)
            .with(method: .POST)
        
        handleRequestByUI(network, animated: true) { [weak self] results in
            guard let self = self else { return }
            if let results = results, let str = String(data: results, encoding: .utf8) {
                //ErrorResponseModel
                if let error = try? JSONDecoder().decode(ErrorResponseModel.self, from: results) {
                    self.showAlerInScreen(title: error.errors?.first?.title ?? "", body: error.errors?.first?.detail ?? "")
                    return
                }
                if str == "true" {
                    self.showAlerInScreen(body: "محصول به لیست مورد علاقه‌های شما اضافه شد")
                }
                if str == "false" {
                    self.showAlerInScreen(body: "محصول از لیست مورد علاقه‌های شما حذف شد")
                }
            }
        }
    }
    
    func checkProductButtonTapped() {
        fetchInit { [weak self] in
            guard let self = self else { return }
            guard CustomerAuth.shared.isLogin else { self.tabBarController?.selectedIndex = 4; return }
            guard !self.isViewed else { self.showAlerInScreen(body: "تنها یکبار امکان بررسی محصول وجود دارد و شما قبلا بررسی نموده‌اید") ; return }
            let config = DownloadManagerConfiguration(isTemporaryFile: true)
            if let productResponseModel = self.snapshot.itemIdentifiers.first {
                if case .info(let info) = productResponseModel {
                    if let reviewDeadlineTime = info.data?.attributes?.review_time {
                        let alertContent = AlertContent(title: .none, subject: "", description: "شما به مدت \(Int(reviewDeadlineTime)) دقیقه امکان بررسی این محصول را دارید. در صورت خروج از این صفحه امکان بررسی مجدد صرفا پس از خرید محصول میسر خواهد بود.")
                        let vc = WarningContentViewController
                            .instantiate()
                            .alert(alertContent)
                        vc.yesButtonTappedHandler = { [weak self] in
                            self?.execute(config: config)
                        }
                        self.present(vc)
                    }
                }
            }
        }
    }
    
    func readBookButtonTapped(button: UIButton) {
        guard let productID = data as? String else { return }
        guard CustomerAuth.shared.isLogin else {
            tabBarController?.selectedIndex = 4
            return
        }
        
        if isPurchase {
            execute(config: nil)
        } else if isProductIntoBasket {
            OrdersRequest(productID: productID)
            button.setTitle("افزودن به سبد", for: .normal)
        } else {
            OrdersRequest(productID: productID)
            button.setTitle("موجود در سبد", for: .normal)
        }
    }
}

// Crypto Extension
enum FilePathError: Error {
    case fileNotFound
    case pdfNotFound
}
extension ProductDetailCollectionViewController {
    static func filePath(fileID: String, originalExtension: String) throws -> String {
        let fileManager = FileManager.default
        var filePath = ""
        let directories : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if let directory = directories.first {
            if originalExtension == "zip" {
                filePath = directory.appendingFormat("/" + fileID)
            } else {
                if originalExtension == "epub" {
                    filePath = directory.appendingFormat("/" + fileID + "." + originalExtension)
                } else {
                    filePath = directory.appendingFormat("/" + fileID + "/" + fileID + "." + originalExtension)
                }
            }
        }
        
        if fileManager.fileExists(atPath: filePath) {
            var pdfPath = ""
            if originalExtension == "zip" {
                if let directory = directories.first {
                    pdfPath = directory.appendingFormat("/" + fileID + "/" + fileID + ".pdf")
                    
                    if fileManager.fileExists(atPath: pdfPath) {
                        //                        print("PDF Existed at", pdfPath)
                        return pdfPath
                    } else {
                        throw FilePathError.pdfNotFound
                    }
                }
            }
            //            print("File Existed at ", filePath)
            return filePath
        } else {
            throw FilePathError.fileNotFound
        }
    }
    
    static func deleteFile(path: String) {
        let fileManager = FileManager.default
        do {
            print("File deleted complete", path)
            try fileManager.removeItem(atPath: path)
        } catch let err {
            print(err)
        }
    }
    
    static func deleteAllFiles(info: ProductResponseModel) {
        let files = info.files
        
        files.forEach { file in
            if let path = try? ProductDetailCollectionViewController.filePath(fileID: file.id!, originalExtension: file.attributes!.originalExtension) {
                if file.attributes!.originalExtension == "zip" {
                    let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                    if let dir = dirs.first {
                        try? FileManager.default.removeItem(atPath: dir.appendingFormat("/" + file.id! + ".zip"))
                        try? FileManager.default.removeItem(atPath: dir.appendingFormat("/" + file.id!))
                    }
                } else {
                    ProductDetailCollectionViewController.deleteFile(path: path)
                }
            }
        }
    }
}

extension ProductDetailCollectionViewController {
    private func readerConfiguration() -> FolioReaderConfig {
        let config = FolioReaderConfig()
        config.shouldHideNavigationOnTap = false
        config.scrollDirection = .horizontalWithVerticalContent
        
        // See more at FolioReaderConfig.swift
        //        config.canChangeScrollDirection = false
        //        config.enableTTS = false
        //        config.displayTitle = true
        //        config.allowSharing = false
        //        config.tintColor = UIColor.blueColor()
        //        config.toolBarTintColor = UIColor.redColor()
        //        config.toolBarBackgroundColor = UIColor.purpleColor()
        //        config.menuTextColor = UIColor.brownColor()
        //        config.menuBackgroundColor = UIColor.lightGrayColor()
        //        config.hidePageIndicator = true
        //        config.realmConfiguration = Realm.Configuration(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("highlights.realm"))
        
        // Custom sharing quote background
        config.quoteCustomBackgrounds = []
        //        if let image = UIImage(named: "demo-bg") {
        //            let customImageQuote = QuoteImage(withImage: image, alpha: 0.6, backgroundColor: UIColor.black)
        //            config.quoteCustomBackgrounds.append(customImageQuote)
        //        }
        
        let textColor = UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0)
        let customColor = UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0)
        let customQuote = QuoteImage(withColor: customColor, alpha: 1.0, textColor: textColor)
        config.quoteCustomBackgrounds.append(customQuote)
        
        return config
    }
    
    func fetchInit(completion: @escaping () -> Void) {
        let network = RestfulAPI<EMPTYMODEL,LoginResponseModel>.init(path: "/v2/init")
            .with(method: .POST)
            .with(auth: .user)
            .with(parameters: ["app_version":"1",
                               "app_sdk":"1",
                               "app_packagename":"hpen_ios"])
        
        handleRequestByUI(network,animated: true) { result in
            CustomerAuth.shared.loginResponseModel = result
            completion()
        }
    }
    
    @objc func reviewTimeEnded(notification: Notification) {
        if let _ = notification.userInfo?["productID"] as? String {
            // check if this product is that preview product
        }
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func startTimer(deadTime: Int, productID: String) {
        print("Timer set for \(deadTime) minute")
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.incrementTime += 1
            if (deadTime*60)+14 == self.incrementTime {
                // invalidate timer
                self.timer?.invalidate()
                self.timer = nil
                self.incrementTime = 0
                // post notif for player vc
                NotificationCenter.default.post(name: .fileReviewTimeEnded, object: nil, userInfo: ["productID":productID])
                print("Preview Time ProductID \(productID) Ended.")
                // delete save files here:
                if let productResponseModel = self.snapshot.itemIdentifiers.first {
                    if case .info(let info) = productResponseModel {
                        ProductDetailCollectionViewController.deleteAllFiles(info: info)
                    }
                }
            }
        })
    }
    
    func execute(config: DownloadManagerConfiguration?) {
        func presentCustomPlayerVC(info: ProductResponseModel) {
            func startTemproryTimer() {
                if let config = config, config.isTemporaryFile {
                    if let reviewDeadlineTime = info.data?.attributes?.review_time, let productID = info.data?.id {
                        // start timer
                        startTimer(deadTime: Int(reviewDeadlineTime), productID: productID)
                    }
                }
            }
            // open vc
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) { [weak self] in
                guard let self = self else { return }
                if let productType = info.data?.attributes?.fileTypeEnum {
                    switch productType {
                    case .MP4:
                        if let fileID = info.files.first?.id, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: "mp4") {
                            let videoURL = URL(fileURLWithPath: filePath)
                            self.startAnimateIndicator()
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                                guard let self = self else { return }
                                if let decryptedData = videoURL.decryptedData {
                                    try? decryptedData.write(to: videoURL)
                                }
                                startTemproryTimer()
                                self.stopAnimateIndicator()
                                let playerController = LandscapeAVPlayerController()
                                let videoURL = URL(fileURLWithPath: filePath)
                                let player = AVPlayer.init(url: videoURL)
                                playerController.player = player
                                self.present(playerController, animated: true) {
                                    player.play()
                                }
                            }
                        }
                        break
                    case .EPUB:
                        if let fileID = info.files.first?.id, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: "epub") {
                            let folioReader = FolioReader()
                            let readerConfiguration = self.readerConfiguration()
                            let epubURL = URL(fileURLWithPath: filePath)
                            print(filePath, epubURL.path, epubURL.relativePath, epubURL.absoluteString)
                            if let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                                let path = "\(directory)"+"/"+fileID+".epub"
                                startTemproryTimer()
                                folioReader.presentReader(parentViewController: self, withEpubPath: path, andConfig: readerConfiguration, shouldRemoveEpub: false)
                            }
                        }
                        break
                    case .PDF:
                        if let fileID = info.files.first?.id, let originalExtension = info.files.first?.attributes?.originalExtension, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                            self.startAnimateIndicator()
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                                guard let self = self else { return }
                                let pdfURL = URL(fileURLWithPath: filePath)
                                if let decryptedData = pdfURL.decryptedData {
                                    try? decryptedData.write(to: pdfURL)
                                }
                                
                                self.present(CustomPDFReaderViewController
                                            .instantiate()
                                            .with(passing: pdfURL), animated: true)
                                startTemproryTimer()
                                self.stopAnimateIndicator()
                            }
                        }
                        break
                    case .ZIP:
                        if let fileID = info.seasonFiles.first?.file.id, let originalExtension = info.seasonFiles.first?.file.attributes?.originalExtension, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                            self.startAnimateIndicator()
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                                guard let self = self else { return }
                                let pdfPath = URL(fileURLWithPath: filePath)
                                if let decryptedData = pdfPath.decryptedData {
                                    try? decryptedData.write(to: pdfPath)
                                }
                                
                                self.present(AudioBookViewController
                                            .instantiate()
                                            .with(passing: info), animated: true)
                                startTemproryTimer()
                                self.stopAnimateIndicator()
                            }
                        }
                        break
                    case .MP3:
                        if let fileID = info.files.first?.id, let originalExtension = info.files.first?.attributes?.originalExtension, let filePath = try? ProductDetailCollectionViewController.filePath(fileID: fileID, originalExtension: originalExtension) {
                            self.startAnimateIndicator()
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                                guard let self = self else { return }
                                let mp3Path = URL(fileURLWithPath: filePath)
                                if let decryptedData = mp3Path.decryptedData {
                                    try? decryptedData.write(to: mp3Path)
                                }
                                
                                self.present(AudioPlayerViewController
                                            .instantiate()
                                            .with(passing: info), animated: true)
                                startTemproryTimer()
                                self.stopAnimateIndicator()
                            }
                        }
                        break
                    }
                }
            }
        }
        
        if let productResponseModel = snapshot.itemIdentifiers.first {
            if case .info(let info) = productResponseModel {
                func download(season: SeasonFile) {
                    let vc = DownloadProgressViewController
                        .instantiate()
                    multiDownloader = nil
                    multiDownloader = MultiFilesDownloader(product: info, masterfile: season.file, otherFiles: season.otherFiles, config: config)
                    multiDownloader?.downloadFiles(completion: { [weak self] (percent,status) in
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.delegate?.downloadProgress(percent: percent, status: status)
                            if status == .finished {
                                presentCustomPlayerVC(info: info)
                                self.multiDownloader = nil
                                if let cell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? ProductInfoCollectionViewCell {
                                    cell.trashButton.alpha = 1
                                }
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
                
                // download and play it next task is here
                let seasons = info.seasonFiles
                if let season = seasons.first {
                    if let productResponseModel = snapshot.itemIdentifiers.first {
                        if case .info(let info) = productResponseModel {
                            if let productType = info.data?.attributes?.fileTypeEnum {
                                if case .MP4 = productType {
                                    if info.seasonFiles.count > 1 {
                                        self.present(MovieBookTableViewController
                                                        .instantiate()
                                                        .with(passing: info))
                                        return
                                    }
                                }
                            }
                        }
                    }
                    // for other file types:
                    download(season: season)
                }
            }
        }
    }
}

class LandscapeAVPlayerController: AVPlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    deinit {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
}
