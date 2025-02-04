//
//  AudioPlayerViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/13/1400 AP.
//
// complete notification center buttons.

import UIKit
import SwiftUI
import MediaPlayer

class AudioPlayerViewController: BaseViewController {
    
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var CoverImageView: UIImageView!
    @IBOutlet weak var playPauseButton: UIButton! // pause.fill // play.fill
    @IBOutlet weak var seekLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton! // timer
    @IBOutlet weak var timeTitleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel! // timer

    private var product: ProductResponseModel {
        return data as! ProductResponseModel
    }
    
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
    
    private var currentFileIndex: Int = 0
    private var multiDownloader: MultiFilesDownloader?
    private var audioPlayer: AudioPlayer?
    
    private var seekBarTimer: Timer?
    private var sleepBarTimer: Timer?
    
    private var sleepBarTimerCountDown = 0
    
    var nowPlayingInfo = [String:Any]()
    let commandCenter = MPRemoteCommandCenter.shared()

    public weak var delegate: ProductDetailCollectionViewControllerDelegate?

    override func configUI() {
        super.configUI()
        NotificationCenter.default.addObserver(self, selector: #selector(reviewTimeEnded(notification:)), name: .fileReviewTimeEnded, object: nil)
        // play first audio file
        playSeasonAt(index: 0)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
         }
         catch {
            // report for an error
         }
    }
    
    override func updateUI() {
        super.updateUI()
        if let forKey = product.data?.id, let savedImage = UserDefaults.standard.value(forKey: forKey) as? Data {
            CoverImageView.image = UIImage(data: savedImage)
        } else {
            if let imageURL = product.data?.attributes?.thumbnailImageURL {
                CoverImageView.loadImage(from: imageURL)
            }
        }

        titleLabel.text = product.data?.attributes?.name
        
        configMPNowPlayingInfoCenter()
        setupMediaPlayerNotificationCenter()
    }
    
    @objc func reviewTimeEnded(notification: Notification) {
        if let productID = notification.userInfo?["productID"] as? String {
            // check if this product is that preview product
            if productID == product.data?.id {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func startPlayer(path: String) {
        let buttonImage = (audioPlayer?.isPaused ?? false) ? UIImage(systemName: "play.fill"):UIImage(systemName: "pause.fill")
        let mp3Path = URL(fileURLWithPath: path)
        
        audioPlayer = nil
        audioPlayer = AudioPlayer(url: mp3Path)
        audioPlayer?.start()
        
        configSeekBar()
        playPauseButton.setImage(buttonImage, for: .normal)
    }
    
    func configSeekBar() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        seekSlider.value = 0
        seekSlider.minimumValue = 0
        seekSlider.maximumValue = audioPlayer.fileDuration
        configSeekBarTimer()
    }
    
    func configSeekBarTimer() {
        let seekJumpDuration: TimeInterval = 1.0
        seekBarTimer?.invalidate()
        seekBarTimer = nil
        seekBarTimer = Timer.scheduledTimer(withTimeInterval: seekJumpDuration, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            guard self.audioPlayer?.isPaused == false else {
                let buttonImage = (self.audioPlayer?.isPaused ?? true) ? UIImage(systemName: "play.fill"):UIImage(systemName: "pause.fill")
                self.playPauseButton.setImage(buttonImage, for: .normal)
                return
            }
            let currentValue = self.seekSlider.value
            print("current seekbar", currentValue)
            let nextValue = currentValue+Float(seekJumpDuration)

            if nextValue < self.seekSlider.maximumValue {
                self.seekSlider.value = nextValue
                let timeHelper = TimeHelper.time(Int(nextValue))
                self.seekLabel.text = "\(timeHelper.hour):\(timeHelper.minute):\(timeHelper.secend)"
            } else {
                // end of audio here *
                print("audio file ended")
                self.audioPlayer?.stop()
                timer.invalidate()
                // for this controller only
                let filesCount = self.product.seasonFiles.count
                let nextFileIndex = self.currentFileIndex+1
                if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
                    self.playSeasonAt(index: nextFileIndex)
                } else {
                    print("Last file play end")
                    self.currentFileIndex = 0
                    self.playSeasonAt(index: self.currentFileIndex) // play first file again
                }
            }
            let buttonImage = (self.audioPlayer?.isPaused ?? true) ? UIImage(systemName: "play.fill"):UIImage(systemName: "pause.fill")
            self.playPauseButton.setImage(buttonImage, for: .normal)
        })
    }
    
    func playSeasonAt(index: Int) {
        let file = product.seasonFiles[index].file
        if let filePath = try? ProductDetailCollectionViewController.filePath(fileID: file.id!, originalExtension: file.attributes!.originalExtension) {
            currentFileIndex = index
            startPlayer(path: filePath)
        } else {
            download(season: product.seasonFiles[index])
        }
    }
    
    func download(season: SeasonFile) {
        guard isPurchase else {
            showAlerInScreen(body: "لطفا برای مشاهده فصل‌های بیشتر محصول را خریداری کنید")
            return
        }
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
                    self.playNextOrBackwardFile(isNext: true)
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
    
    func playNextOrBackwardFile(isNext: Bool) {
        let filesCount = self.product.seasonFiles.count
        let nextFileIndex =  isNext ? self.currentFileIndex+1:self.currentFileIndex-1
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

    @IBAction func seekSliderValueChanged(_ sender: UISlider) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        let timeHelper = TimeHelper.time(Int(sender.value))
        self.seekLabel.text = "\(timeHelper.hour):\(timeHelper.minute):\(timeHelper.secend)"
        audioPlayer.sliderValueChanged(value: sender.value)
    }
    
    @IBAction func playAndPauseButtonTapped(_ sender: UIButton) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        let buttonImage = audioPlayer.isPaused ? UIImage(systemName: "play.fill"):UIImage(systemName: "pause.fill")
        
        if audioPlayer.isPaused {
            playPauseButton.setImage(buttonImage, for: .normal)
            audioPlayer.play()
        } else {
            playPauseButton.setImage(buttonImage, for: .normal)
            audioPlayer.pause()
        }
    }
    
    @IBAction func menuListButtonTapped(_ sender: Any) {
        let items: [MoreModel] = product.seasonFiles.map { MoreModel(id: $0.file.id!, key: "", faKey: "", name: $0.file.attributes!.name!, imageName: "chart.bar.fill") }
        let vc = MoreTableViewController
            .instantiate()
            .with(passing: items)
        vc.delegate = self
        let file = product.seasonFiles[currentFileIndex].file
        vc.currentModel = MoreModel(id: file.id!, key: "", faKey: "", name: file.attributes!.name!, imageName: "chart.bar.fill")
        present(vc)
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        let currentValue = seekSlider.value
        let nextValue = currentValue+15
        if nextValue < seekSlider.maximumValue-15 {
            seekSlider.value = nextValue
            audioPlayer.sliderValueChanged(value: nextValue)
            let timeHelper = TimeHelper.time(Int(nextValue))
            self.seekLabel.text = "\(timeHelper.hour):\(timeHelper.minute):\(timeHelper.secend)"
        } else {
            // no forward available here
            // only for audio
            let filesCount = self.product.seasonFiles.count
            let nextFileIndex = self.currentFileIndex+1
            if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
                audioPlayer.stop()
                self.playSeasonAt(index: nextFileIndex)
            }
        }
    }
    
    @IBAction func backwardButtonTapped(_ sender: Any) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        let currentValue = seekSlider.value
        let backwardValue = currentValue-15
        if backwardValue >= 0 {
            seekSlider.value = backwardValue
            let timeHelper = TimeHelper.time(Int(backwardValue))
            self.seekLabel.text = "\(timeHelper.hour):\(timeHelper.minute):\(timeHelper.secend)"
            audioPlayer.sliderValueChanged(value: backwardValue)
        } else {
            // no backward available here
            // only for audio
            let filesCount = self.product.seasonFiles.count
            let nextFileIndex = self.currentFileIndex-1
            if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
                audioPlayer.stop()
                self.playSeasonAt(index: nextFileIndex)
            }
        }
    }
    
    @IBAction func timerButtonTapped(_ sender: UIButton) {
        if sleepBarTimer == nil {
            let times = ["15","30","45","60","90","آخر فصل"]
            let items = times.map { MoreModel.init(id: "\((Int($0) ?? 0)*60)", key: "minutes", faKey: "", name: $0, imageName: "timer") }
            var moresWithDetails = items.map { MoreModel.init(id: $0.id, key: $0.key, faKey: $0.faKey, name: "\($0.name) دقیقه") }
            moresWithDetails[moresWithDetails.count-1].name = "آخر فصل"
            let vc = MoreTableViewController
                .instantiate()
                .with(passing: moresWithDetails)
            vc.delegate = self
            present(vc)
        } else {
            sleepBarTimer?.invalidate()
            sleepBarTimer = nil
            timerButton.setTitle("", for: .normal)
            timeTitleButton.setTitle("خاموشی خودکار", for: .normal)
            timerButton.setImage(UIImage(systemName: "timer"), for: .normal)
        }
    }
    
    deinit {
        print("deinit audioplayer vc")
    }
}

extension AudioPlayerViewController: MoreTableViewControllerDelegate {
    func headerSelected(_ more: MoreModel) {
        if more.key == "" {
            // season file selection
            if let firstFileIndex = product.seasonFiles.firstIndex(where: { seasonFile in
                seasonFile.file.id == more.id
            }) {
                playSeasonAt(index: firstFileIndex)
            }
        }
        if more.key != "" {
            sleepBarTimer?.invalidate()
            sleepBarTimer = nil
            guard let audioPlayer = audioPlayer else {
                sleepBarTimerCountDown = 0
                timeTitleButton.setTitle("خاموشی خودکار", for: .normal)
                timerButton.setTitle("", for: .normal)
                timerButton.setImage(UIImage(systemName: "timer"), for: .normal)
                sleepBarTimer?.invalidate()
                sleepBarTimer = nil
                return
            }
            // timer..
            if let countDownTime = Int(more.id) {
                // at spectific time
                if countDownTime > 0 {
                    sleepBarTimerCountDown = countDownTime
                } else {
                    // until end season file
                    sleepBarTimerCountDown = Int(audioPlayer.fileDuration)
                }
            }
            sleepBarTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
                guard let self = self else { return }
                if self.sleepBarTimerCountDown > 0 {
                    self.sleepBarTimerCountDown -= 1
                    self.timeTitleButton.setTitle("", for: .normal)
                    self.timerButton.setImage(nil, for: .normal)
                    let timeHelper = TimeHelper.time(self.sleepBarTimerCountDown)
                    self.timerButton.setTitle("\(timeHelper.hour):\(timeHelper.minute):\(timeHelper.secend)", for: .normal)
                } else {
                    self.timerButton.setTitle("", for: .normal)
                    self.timeTitleButton.setTitle("خاموشی خودکار", for: .normal)
                    self.timerButton.setImage(UIImage(systemName: "timer"), for: .normal)
                    self.sleepBarTimer?.invalidate()
                    self.sleepBarTimer = nil
                    audioPlayer.stop()
                }
            })
        }
    }
}

extension AudioPlayerViewController {
    func setupMediaPlayerNotificationCenter() {
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed}
            guard let audioPlayer = self.audioPlayer else { return .commandFailed }
            let buttonImage = audioPlayer.isPaused ? UIImage(systemName: "play.fill"):UIImage(systemName: "pause.fill")
            self.playPauseButton.setImage(buttonImage, for: .normal)
            audioPlayer.play()

            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self]  (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed}
            guard let audioPlayer = self.audioPlayer else { return .commandFailed }
            let buttonImage = audioPlayer.isPaused ? UIImage(systemName: "play.fill"):UIImage(systemName: "pause.fill")
            self.playPauseButton.setImage(buttonImage, for: .normal)
            audioPlayer.pause()
            
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            guard let audioPlayer = self.audioPlayer else { return .commandFailed }
            let filesCount = self.product.seasonFiles.count
            let nextFileIndex = self.currentFileIndex-1
            if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
                audioPlayer.stop()
                self.playSeasonAt(index: nextFileIndex)
            }

            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self = self else { return .commandFailed }
            guard let audioPlayer = self.audioPlayer else { return .commandFailed }
            let filesCount = self.product.seasonFiles.count
            let nextFileIndex = self.currentFileIndex+1
            if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
                audioPlayer.stop()
                self.playSeasonAt(index: nextFileIndex)
            }
            
            return .success
        }
    }
    
    func configMPNowPlayingInfoCenter() {
        let file = product.seasonFiles[currentFileIndex].file

        nowPlayingInfo[MPMediaItemPropertyTitle] = file.attributes?.name ?? ""
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = product.data?.attributes?.name ?? ""
        nowPlayingInfo[MPMediaItemPropertyArtist] = product.data?.attributes?.authorsName ?? ""
        if let audioPlayer = audioPlayer {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer.fileDuration)
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: CGSize(width: 100, height: 100), requestHandler: { (_) -> UIImage in
            return UIImage()
        })

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
