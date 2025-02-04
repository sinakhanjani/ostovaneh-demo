//
//  URLExtension.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/24/1400 AP.
//

import Foundation

enum Base64Error: Error {
    case faildDecode
}
extension URL {
    func decode(_ string: [UInt8]) throws -> [UInt8] {
        let lookupTable: [UInt8] = [
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 62, 64, 63,
            52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
            64, 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14,
            15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 63,
            64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
            41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
        ]
        
        let remainder = string.count % 4
        let length = (string.count - remainder) / 4
        
        var decoded = [UInt8]()
        decoded.reserveCapacity(length)
        
        var index = 0
        var i0: UInt8 = 0
        var i1: UInt8 = 0
        var i2: UInt8 = 0
        var i3: UInt8 = 0
        
        while index &+ 4 < string.count {
            i0 = lookupTable[numericCast(string[index])]
            i1 = lookupTable[numericCast(string[index &+ 1])]
            i2 = lookupTable[numericCast(string[index &+ 2])]
            i3 = lookupTable[numericCast(string[index &+ 3])]
            
            if i0 > 63 || i1 > 63 || i2 > 63 || i3 > 63 {
                throw Base64Error.faildDecode
            }
            
            decoded.append(i0 << 2 | i1 >> 4)
            decoded.append(i1 << 4 | i2 >> 2)
            decoded.append(i2 << 6 | i3)
            index += 4
        }
        if string.count &- index > 1 {
            i0 = lookupTable[numericCast(string[index])]
            i1 = lookupTable[numericCast(string[index &+ 1])]
            if i1 > 63 {
                guard string[index] == 61 else {
                    throw Base64Error.faildDecode
                }
                
                return decoded
            }
            if i2 > 63 {
                guard string[index &+ 2] == 61 else {
                    throw Base64Error.faildDecode
                }
                
                return decoded
            }
            decoded.append(i0 << 2 | i1 >> 4)
            if string.count &- index > 2 {
                i2 = lookupTable[numericCast(string[index &+ 2])]
                
                if i2 > 63 {
                    guard string[index &+ 2] == 61 else {
                        throw Base64Error.faildDecode
                    }
                    
                    return decoded
                }
                decoded.append(i1 << 4 | i2 >> 2)
                
                if string.count &- index > 3 {
                    i3 = lookupTable[numericCast(string[index &+ 3])]
                    
                    if i3 > 63 {
                        guard string[index &+ 3] == 61 else {
                            throw Base64Error.faildDecode
                        }
                        
                        return decoded
                    }
                    decoded.append(i2 << 6 | i3)
                }
            }
        }
        
        return decoded
    }
    
    public var decryptedData: Data? {
        var content = String()
        var decryptedContent = String()
        var decodedData = Data()

        // Step1: Convert content to String
        if let contentOf = try? String(contentsOf: self) {
            content = contentOf
        }
        // Step2: Decrypt as AES Encryption
        if content != "" {
            decryptedContent = try! content.aesDecrypt()
        } else {
            return nil
        }
        // Step3: Convert Data to UIn8
        let covertedBytes: [UInt8] = Array(decryptedContent.utf8)
        // Step4: Decode by base64
        guard let base64DecodedBytes = try? decode(covertedBytes) else { return nil }
        decodedData = base64DecodedBytes.data
        
        return decodedData
    }
}
