//
//  AudioBookViewController.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/14/1400 AP.
//

import UIKit
import MediaPlayer

class AudioBookViewController: BaseViewController, UITextFieldDelegate  {
    
    private var product: ProductResponseModel {
        return data as! ProductResponseModel
    }

    @IBOutlet weak var controlBoxView: UIView!
    @IBOutlet weak var pageTextField: UITextField!
    @IBOutlet weak var totalPageLabel: UILabel!
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton! // pause.fill // play.fill
    @IBOutlet weak var isAutoPlaySwitch: UISwitch!

    public weak var delegate: ProductDetailCollectionViewControllerDelegate?
    private weak var pdfController: PDFViewController!
    private var currentFileIndex: Int = 0
    private var audioPlayer: AudioPlayer?
    private var seekBarTimer: Timer?
    let button = UIButton()

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
    
    var nowPlayingInfo = [String:Any]()
    var isUp = true

    override func configUI() {
        super.configUI()
        view.bindToKeyboard()
        if let file = product.seasonFiles.first?.file {
            if let filePath = try? ProductDetailCollectionViewController.filePath(fileID: file.id!, originalExtension: file.attributes!.originalExtension) {
                let pdfURL = URL(fileURLWithPath: filePath)
                if let pdfDocument = document(pdfURL) {
                    showDocument(pdfDocument)
                }
            }
        }
        pageTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reviewTimeEnded(notification:)), name: .fileReviewTimeEnded, object: nil)
        // play first audio file
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
            guard let self = self else { return }
            self.playSeasonAt(index: self.currentFileIndex)
        }
        // notification center
        setupMediaPlayerNotificationCenter()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
         }
         catch {
            // report for an error
         }
    }
    
    override func updateUI() {
        super.updateUI()
        button.frame = CGRect(x: 16, y: 8, width: 64, height: 64)
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: "arrowtriangle.up.circle"), for: .normal)
        button.addTarget(self, action: #selector(upButtonTapped), for: .touchUpInside)
        button.alpha = 0
        if #available(iOS 15.0, *) {
            button.configuration = .plain()
        } 
        view.addSubview(button)
    }
    
    @objc func reviewTimeEnded(notification: Notification) {
        if let productID = notification.userInfo?["productID"] as? String {
            // check if this product is that preview product
            if productID == product.data?.id {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        view.endEditing(true)
        let fileCount = product.seasonFiles[0].otherFiles?.count ?? 0
        guard currentFileIndex <= fileCount-1 else { return }
        if let currentFile = self.product.seasonFiles[0].otherFiles?[currentFileIndex], let relatedFrom = currentFile.attributes?.relatedFrom {
            self.pdfController.movePDFViewPage(to: relatedFrom-1)
        }
    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
        view.endEditing(true)
        if let index = Int(pageTextField.text!.toEnNumber), index > 0 {
            if index-1 <= pdfController.document.pageCount-1 {
                currentFileIndex = index-1
                pdfController.movePDFViewPage(to: currentFileIndex)
                // play sound for item
                let fileCount = product.seasonFiles[0].otherFiles?.count ?? 0
                if currentFileIndex <= fileCount-1 {
                    playSeasonAt(index: currentFileIndex)
                } else {
                    audioPlayer?.stop()
                    audioPlayer = nil
                    seekSlider.setValue(0, animated: true)
                }
            }
        }
    }
    
    /// Initializes a document with the name of the pdf in the file system
    private func document(_ name: String) -> PDFDocument? {
        guard let documentURL = Bundle.main.url(forResource: name, withExtension: "pdf") else { return nil }
        return PDFDocument(url: documentURL)
    }
    
    /// Initializes a document with the data of the pdf
    private func document(_ data: Data) -> PDFDocument? {
        return PDFDocument(fileData: data, fileName: "PDF")
    }
    
    /// Initializes a document with the remote url of the pdf
    private func document(_ remoteURL: URL) -> PDFDocument? {
        return PDFDocument(url: remoteURL)
    }
    
    private func showDocument(_ document: PDFDocument) {
        let image = UIImage(named: "")
        let controller = PDFViewController.createNew(with: document, title: "", actionButtonImage: image, actionStyle: .activitySheet)
        controller.backgroundColor = .white
        pdfController = controller
        pdfController.delegate = self
        let totalPagesCount = controller.document.pageCount
        totalPageLabel.text = "از   \(totalPagesCount)"
        addPDF(controller: controller)
    }
    
    func addPDF(controller: PDFViewController) {
        addChild(controller)
        view.addSubview(controller.view)
        view.sendSubviewToBack(controller.view)
        
        let frame = view.frame
        controller.view.frame = CGRect(x: .zero, y: .zero, width: frame.width, height: frame.height-150)
        controller.didMove(toParent: self)
    }
    
    // MARK: -Player
    func startPlayer(path: String) {
        let buttonImage = (audioPlayer?.isPaused ?? false) ? UIImage(systemName: "play.fill"):UIImage(systemName: "pause.fill")
        let mp3Path = URL(fileURLWithPath: path)
        
        audioPlayer = nil
        audioPlayer = AudioPlayer(url: mp3Path)
        audioPlayer?.start()
        if let currentFile = self.product.seasonFiles[0].otherFiles?[currentFileIndex], let relatedFrom = currentFile.attributes?.relatedFrom {
            pdfController.movePDFViewPage(to: relatedFrom-1)
        }
        configSeekBar()
        playPauseButton.setImage(buttonImage, for: .normal)
        pageTextField.text = "\(currentFileIndex+1)"
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
        UIApplication.shared.isIdleTimerDisabled = true
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
//            print("current seekbar", currentValue)
            let nextValue = currentValue+Float(seekJumpDuration)

            if nextValue < self.seekSlider.maximumValue {
                self.seekSlider.value = nextValue
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
                // end of audio here *
                print("audio file ended")
                self.audioPlayer?.stop()
                timer.invalidate()
                // for this controller only
                let filesCount = self.product.seasonFiles[0].otherFiles?.count ?? 0
                let nextFileIndex = self.currentFileIndex+1
                if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
                    if self.isAutoPlaySwitch.isOn { // of auto next is on
                        self.playSeasonAt(index: nextFileIndex)
                    } else { // if auto next if off
                        self.audioPlayer = nil
                    }
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
        let fileCount = product.seasonFiles[0].otherFiles?.count ?? 0
        guard index <= fileCount-1 else {
            audioPlayer?.stop()
            audioPlayer = nil
            seekSlider.setValue(0, animated: true)
            return
        }
        guard let file = product.seasonFiles[0].otherFiles?[index] else {
            // file play ended
            return
        }
        if let filePath = try? ProductDetailCollectionViewController.filePath(fileID: file.id!, originalExtension: file.attributes!.originalExtension) {
            let mp3Path = URL(fileURLWithPath: filePath)
            
            if let decryptedData = mp3Path.decryptedData {
                try? decryptedData.write(to: mp3Path)
            }
            
            currentFileIndex = index
            startPlayer(path: filePath)
        }
    }

    func playNextOrBackwardFile(isNext: Bool) {
        let filesCount = self.product.seasonFiles[0].otherFiles?.count ?? 0
        let nextFileIndex =  isNext ? self.currentFileIndex+1:self.currentFileIndex-1
        if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
            // go to the next file available + decrypt and playit
            guard let file = self.product.seasonFiles[0].otherFiles?[currentFileIndex] else {
                return
            }
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
    
    
    func forwardSound() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        let filesCount = self.product.seasonFiles[0].otherFiles?.count ?? 0
        let nextFileIndex = self.currentFileIndex+1
        if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
            audioPlayer.stop()
            self.playSeasonAt(index: nextFileIndex)
        }
    }
    
    func backwardSound() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        let filesCount = self.product.seasonFiles[0].otherFiles?.count ?? 0
        let nextFileIndex = self.currentFileIndex-1
        if (nextFileIndex >= 0) && (nextFileIndex <= filesCount-1) {
            audioPlayer.stop()
            self.playSeasonAt(index: nextFileIndex)
        }
    }

    @IBAction func seekSliderValueChanged(_ sender: UISlider) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        audioPlayer.sliderValueChanged(value: sender.value)
    }
    
    @IBAction func playAndPauseButtonTapped(_ sender: UIButton) {
        guard let audioPlayer = audioPlayer else {
            playSeasonAt(index: currentFileIndex)
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
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        let currentValue = seekSlider.value
        let nextValue = currentValue+15
        if nextValue < seekSlider.maximumValue-15 {
            seekSlider.value = nextValue
            audioPlayer.sliderValueChanged(value: nextValue)
        } else {
            // no forward available here
            // only for audio
            forwardSound()
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
            audioPlayer.sliderValueChanged(value: backwardValue)
        } else {
            // no backward available here
            // only for audio
            backwardSound()
        }
    }
    
    @IBAction func forwardSoundButtonTapped(_ sender: Any) {
        forwardSound()
    }
    
    @IBAction func backSoundButtonTapped(_ sender: Any) {
        backwardSound()
    }
    
    @IBAction func rotationButtonTapped() {
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    

    @IBAction func upAndDownButtonTapped(_ sender: UIButton) {
        //arrowtriangle.down.circle
        //arrowtriangle.up.circle
        controlBoxView.alpha = 0
        pdfController.view.frame = view.frame
        button.alpha = 1
        isUp = true
    }
    
    @objc func upButtonTapped() {
        controlBoxView.alpha = 1
        button.alpha = 0
        let frame = view.frame
        pdfController.view.frame = CGRect(x: .zero, y: .zero, width: frame.width, height: frame.height-150)
        isUp = false
    }
    
    deinit {
        print("deinit")
    }
}

// complete here.
extension AudioBookViewController: PDFViewControllerDelegate {
    func PDFPage(moveTo currentPageIndex: Int, forward: Bool) {
        let fileCount = product.seasonFiles[0].otherFiles?.count ?? 0
        if currentFileIndex <= fileCount-1 {
            if let currentFile = self.product.seasonFiles[0].otherFiles?[currentFileIndex], let relatedFrom = currentFile.attributes?.relatedFrom, let relatedTo = currentFile.attributes?.relatedTo {
                print("relatedFrom:\(relatedFrom-1), relatedTo:\(relatedTo), currentPageIndex:\(currentPageIndex), currentFileIndex:\(currentFileIndex)")
                if (relatedFrom-1 != currentPageIndex) && (relatedTo-1 != currentPageIndex) {
                    if forward {
                        print(currentPageIndex,currentFileIndex)
                        forwardSound()
                    } else {
                        backwardSound()
                    }
                }
            }
        }
    }
}

extension AudioBookViewController {
    func setupMediaPlayerNotificationCenter() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
//            self.playAndPauseButtonTapped(self.playPauseButton)
//            return .success
//        }
//        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
//            self.playAndPauseButtonTapped(self.playPauseButton)
//            return .success
//        }
//        commandCenter.previousTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
//            self.playNextOrBackwardFile(isNext: false)
//            return .success
//        }
//        commandCenter.nextTrackCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
//            self.playNextOrBackwardFile(isNext: true)
//            return .success
//        }
    }
    
    func configNotificationCenter() {
//        guard let file = product.seasonFiles[0].otherFiles?[currentFileIndex] else {
//            return
//        }
//
//        nowPlayingInfo[MPMediaItemPropertyTitle] = file.attributes?.name ?? ""
//        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = product.data?.attributes?.name ?? ""
//        nowPlayingInfo[MPMediaItemPropertyArtist] = product.data?.attributes?.authorsName ?? ""
//        if let audioPlayer = audioPlayer {
//            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: audioPlayer.fileDuration)
//        }
//        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork.init(boundsSize: CGSize(width: 100, height: 100), requestHandler: { (_) -> UIImage in
//            return UIImage()
//        })
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateNotificationCenter(duration: Float) {

    }
}
