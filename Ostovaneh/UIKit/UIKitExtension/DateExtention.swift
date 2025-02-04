//
//  DateExt.swift
//  Master
//
//  Created by Sina khanjani on 9/16/1399 AP.
//

import Foundation

extension Date {
    ///Getting the Date from String and formatting the Date to display it or send to API are common tasks. The standard way to convert takes three lines of code. Let’s see how to make it shorter:
    func toString(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}
