//
//  MultiDownloader.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/28/1400 AP.
//

import Foundation
import SwiftUI

class MultiFilesDownloader {
    private var downloadmanagers: [DownloadManager]
    private var downloadGroup: DispatchGroup?
    private var product: ProductResponseModel
    private let config: DownloadManagerConfiguration?

    init(product: ProductResponseModel, masterfile: IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>, otherFiles: [IncludedTypeModel<FileAttributeModel,EMPTYHASHABLEMODEL>]?, config: DownloadManagerConfiguration? = nil) {
        var items: [DownloadManager] = []
        // add master to download manager
        let masterPath = masterfile.attributes!.url!
//        if let config = config {
//            masterPath = config.isTemporaryFile ? masterfile.attributes!.checkTrialURL!:masterfile.attributes!.url!
//        }
        let item = DownloadManager(path: masterPath, fileExtension: masterfile.attributes!.fileExtension!, fileID: masterfile.id!, originalFileExtension: masterfile.attributes!.originalExtension)!
        items.append(item)
        // add other related files to download manager
        if let otherFiles = otherFiles {
            let others: [DownloadManager] = otherFiles.map({ file in
                let path = file.attributes!.url!
//                if let config = config {
//                    path = config.isTemporaryFile ? file.attributes!.checkTrialURL!:file.attributes!.url!
//                }
                let downloadManager = DownloadManager(path: path, fileExtension: file.attributes!.fileExtension!, fileID: file.id!, originalFileExtension: file.attributes!.originalExtension)
                if let config = config {
                    downloadManager?.configuration = config
                }
                
                return downloadManager!
            })
            
            items.append(contentsOf: others)
        }
        
        self.downloadmanagers = items
        self.product = product
        self.config = config
    }
    
    func downloadFiles(completion: ((_ percent: Int,_ status: DownloadStatus) -> Void)?) {
        downloadGroup = DispatchGroup()
        var totalDownloadedFiles = 0
        downloadmanagers = downloadmanagers.filter { downloadManger in
            if let _ = try? ProductDetailCollectionViewController.filePath(fileID: downloadManger.fileID, originalExtension: downloadManger.originalFileExtension) {
                return false
            }
            return true
        }
        
        let totalFiles = downloadmanagers.count
        if totalDownloadedFiles == 0 && !downloadmanagers.isEmpty {
            completion?(0,.started)
        }
        for downloadManager in downloadmanagers {
            if totalFiles > 1 {
                downloadGroup?.enter()
            }
            downloadManager.downloadFile()
            downloadManager.calculateRemainingProgressPercent { [weak self] (filePercent,status) in
                guard let self = self else { return }
                if totalFiles == 1 {
                    print("Total \(totalFiles) files, download remaining file:\(totalDownloadedFiles) and percent:\(filePercent)% fileID:\(downloadManager.fileID) with status: \(status)")
                    if status == .finished {
                        totalDownloadedFiles = 0
                        self.downloadGroup = nil
                        if self.config == nil { // means file is not temprory so encode to archiveURL
                            ProductResponseModel.addProduct(item: self.product)
                        }
                    }
                    completion?(filePercent,status)
                } else {
                    if status == .finished {
                        totalDownloadedFiles += 1
                        let percent = ((Double(totalDownloadedFiles)/Double(totalFiles))*100.0)
                        print("Total \(totalFiles) files, download remaining file:\(totalDownloadedFiles) and percent:\(percent)% fileID:\(downloadManager.fileID) with status: \(status)")
                        completion?(Int(percent),.downloading)
                        self.downloadGroup?.leave()
                    }
                }
            }
        }
        if (totalFiles > 1) || (totalFiles == 0) {
            self.downloadGroup?.notify(queue: DispatchQueue.main) { [weak self] in
                guard let self = self else { return }
                print("->All Files Downloaded Complete<-")
                ProductResponseModel.addProduct(item: self.product)
                totalDownloadedFiles = 0
                self.downloadGroup = nil
                completion?(100,.finished)
            }
        }
    }
    
    func cancelDownloadFiles() {
        let availableDownloadMangers = downloadmanagers.filter { downloadManger in
            if let path = try? ProductDetailCollectionViewController.filePath(fileID: downloadManger.fileID, originalExtension: downloadManger.originalFileExtension) {
                // ->for future you must remove the real file in url here<-
                if downloadManger.originalFileExtension == "zip" {
                    let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                    if let dir = dirs.first {
                        try? FileManager.default.removeItem(atPath: dir.appendingFormat("/" + downloadManger.fileID + ".zip"))
                        try? FileManager.default.removeItem(atPath: dir.appendingFormat("/" + downloadManger.fileID))
                    }
                } else {
                    ProductDetailCollectionViewController.deleteFile(path: path)
                }
                return false
            }
            return true
        }
        
        for downloadManager in availableDownloadMangers {
            downloadManager.cancelDownload()
        }
    }
}
