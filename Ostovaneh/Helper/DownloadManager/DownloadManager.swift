//
//  DownloadManager.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/24/1400 AP.
//

import Foundation
import Zip

enum DownloadStatus {
    case finished
    case failed
    case downloading
    case canceled
    case started
}

struct DownloadManagerConfiguration {
    let isTemporaryFile: Bool
}

class DownloadManager: NSObject {
    
    private var urlRequest: URLRequest
    public var fileExtension: String
    public var originalFileExtension: String
    public var fileID: String
    private var archiveURL: URL
    private var temporaryURL: URL
    private let urlSessionConfiguration: URLSessionConfiguration
    
    public var configuration = DownloadManagerConfiguration(isTemporaryFile: false)
    
    private var urlSessionDownloadTask: URLSessionDownloadTask?
    private var dlPercentCompletion: ((_ percent: Int,_ status: DownloadStatus) -> Void)?
    
    init?(path: String, fileExtension: String, fileID: String, originalFileExtension: String) {
        guard let url = URL(string: path) else { return nil }
        var urlRequest = URLRequest(url: url)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let token = CustomerAuth.shared.token {
            urlRequest.allHTTPHeaderFields = ["Authorization": "Bearer " + token]
        }
        urlRequest.httpMethod = "GET"
        // this header send because of get total file size from server
        urlRequest.addValue("identity", forHTTPHeaderField: "Accept-Encoding")
        // init
        self.urlRequest = urlRequest
        self.fileExtension = fileExtension
        self.originalFileExtension = originalFileExtension
        self.fileID = fileID
        self.urlSessionConfiguration = URLSessionConfiguration.default//.background(withIdentifier: "com.ostovaneh.bgSession.\(fileID)")
        urlSessionConfiguration.sharedContainerIdentifier = "group.swift.apps"

        // init urls
        self.archiveURL = documentsDirectory
            .appendingPathComponent("\(fileID).\(fileExtension)")
        self.temporaryURL = documentsDirectory
            .appendingPathComponent("\(fileID).\(fileExtension)")
    }
    
    private lazy var downloadsSession: URLSession = {
        return URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue:  OperationQueue())
    }()
    
    public func downloadFile() {
        urlSessionDownloadTask = downloadsSession.downloadTask(with: urlRequest)
        urlSessionDownloadTask?.resume()
    }
    
    public func cancelDownload() {
        urlSessionDownloadTask?.cancel()
        urlSessionDownloadTask = nil
    }
    
    public func calculateRemainingProgressPercent(completion: ((_ percent: Int,_ status: DownloadStatus) -> Void)?) {
        dlPercentCompletion = completion
    }
}

extension DownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let remainingPercent = Int((Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) * 100)
//            print("Downloading \(remainingPercent)% ...")
            dlPercentCompletion?(remainingPercent,.downloading)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let filemanager = FileManager.default

        do {
            if configuration.isTemporaryFile {
                // this scope use when file download for read test in application
                try filemanager.copyItem(at: location, to: temporaryURL)
            } else {
                // this scope use when file need to save in a real url archive direction
                try filemanager.copyItem(at: location, to: archiveURL)
            }
            // remove entery downloadTask file from location
            try FileManager.default.removeItem(at: location)
            // let check original url file from configuration
            let url: URL = configuration.isTemporaryFile ? temporaryURL:archiveURL
            
            if fileExtension == "zip" {
                let _ = try Zip.quickUnzipFile(url)
                try FileManager.default.removeItem(at: url)
//                print("Unzip URL: ", unzipURL)
//                print("didFinishDownloadingTo fileID:\(fileID) at location: \(unzipURL)")
            }
            
            dlPercentCompletion?(100,.finished)
        } catch (let error) {
            print("Could not unzip this file: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if task.state == .canceling {
            task.cancel()
            dlPercentCompletion?(0,.canceled)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        //
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // download is failed here. you can use new urlSession in here for completionHandler: @escaping (URLRequest?) -> Void)
        dlPercentCompletion?(0,.failed)
        completionHandler(.none)
    }
}

/*
 MARK: -Epub Zip Password:
 try SSZipArchive.unzipFile(atPath: withEpubPath, toDestination: bookBasePath, overwrite: true, password: "92e8d7c670ea01f57edc230c59668765")
 */
