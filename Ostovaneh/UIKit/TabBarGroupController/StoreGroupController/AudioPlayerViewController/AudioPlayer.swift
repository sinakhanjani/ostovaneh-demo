//
//  AudioPlayer.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/13/1400 AP.
//

import Foundation
import AVKit
import MediaPlayer

class AudioPlayer {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    var isPaused = false

    var fileDuration: Float {
        if let currentTime = avPlayer.currentItem?.asset.duration {
            let seconds : Float64 = CMTimeGetSeconds(currentTime)
            return Float(seconds)
        }
        
        return 0
    }
    
    lazy var avPlayer : AVQueuePlayer = {
        return AVQueuePlayer()
    }()
    
    func start() {
        let playerItem = AVPlayerItem(url: url)
        avPlayer.insert(playerItem, after: nil)
        avPlayer.volume = 1.0
        avPlayer.play()
        isPaused = false
    }
    
    func play() {
        avPlayer.play()
        isPaused = false
    }
    
    func stop() {
        if avPlayer.timeControlStatus == .playing  {
            avPlayer.pause()
            let zeroSecend = Int64(0)
            let targetTime:CMTime = CMTimeMake(value: zeroSecend, timescale: 1)
            avPlayer.seek(to: targetTime)
            isPaused = true
        }
    }
    
    func pause() {
        if avPlayer.timeControlStatus == .playing  {
            avPlayer.pause()
            isPaused = true
        }
    }
    
    func sliderValueChanged(value: Float) {
        guard value >= 0 && value <= fileDuration else {
            return
        }
        guard !isPaused else {
            start()
            return
        }
        let seconds : Int64 = Int64(value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        avPlayer.seek(to: targetTime)
        isPaused = false
    }
    
    func sliderLongPressed(sender: UILongPressGestureRecognizer) {
        if let slider = sender.view as? UISlider {
            if slider.isHighlighted { return }
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            let seconds : Int64 = Int64(value)
            let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
            avPlayer.seek(to: targetTime)
            isPaused = false
        }
    }
    
    deinit {
        avPlayer.pause()
        avPlayer.removeAllItems()
    }
}
