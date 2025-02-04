//
//  UIDevice.swift
//  Master
//
//  Created by Sina khanjani on 9/16/1399 AP.
//

import UIKit
import AudioToolbox

extension UIDevice {
    /// The iPhone vibration can be a cool effect for button taps and other feedback from devices. For iPhone vibration there is a special kind of sound, handled by the AudioToolbox framework.
    /// Including AudioToolbox to all UIViewControllers with vibration is annoying, and logically vibration is more of a device function (it doesn’t come from the speakers but from the device itself) than playing sounds. This extensions allows to simplify it to one line:
    static func vibrate() {
        AudioServicesPlaySystemSound(1519)
    }
}
