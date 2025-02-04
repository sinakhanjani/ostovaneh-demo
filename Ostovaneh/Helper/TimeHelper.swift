//
//  TimeHelper.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 10/17/1400 AP.
//

import Foundation

class TimeHelper {
    
    private var timer: Timer!
    private var secend: Int = 0
    
    public private(set) var elapsedTimeInSecond: Int = 0

    internal init(elapsedTimeInSecond: Int) {
        self.elapsedTimeInSecond = elapsedTimeInSecond
        self.secend = elapsedTimeInSecond
    }
    
    public func start(completion: @escaping (_ time: (second: String, minute: String)) -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.elapsedTimeInSecond -= 1
            
            completion(self.time())

            if self.elapsedTimeInSecond == 0 {
                self.pauseTimer()
            }
        })
    }
    
    public func resetTimer() {
        timer?.invalidate()
        elapsedTimeInSecond = secend
    }

    public func pauseTimer() {
        timer?.invalidate()
    }
    
    func time() -> (second: String, minute: String) {
        let secondText = String(format: "%02d", elapsedTimeInSecond % 60)
        let minuteText = String(format: "%02d", (elapsedTimeInSecond / 60) % 60)

        return (second: secondText, minute: minuteText)
    }
    
    static func time(_ elapsedTimeInSecond: Int) -> (secend: String, minute: String, hour: String, day: String) {
        let secendText = String(format: "%02d", elapsedTimeInSecond % 60)
        let minuteText = String(format: "%02d", (elapsedTimeInSecond / 60) % 60)
        let hourText = String(format: "%02d", ((elapsedTimeInSecond/60)/60) % 60)
        let dayText = String(format: "%02d", (((elapsedTimeInSecond/60)/60)/24))

        return (secend: secendText, minute: minuteText, hour: hourText, day: dayText)
    }
}
