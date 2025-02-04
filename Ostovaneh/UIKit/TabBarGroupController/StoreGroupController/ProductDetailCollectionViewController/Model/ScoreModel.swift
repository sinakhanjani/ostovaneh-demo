//
//  ScoreModel.swift
//  Ostovaneh
//
//  Created by Sina khanjani on 9/6/1400 AP.
//

import Foundation


// MARK: - ScoreAttributeModel
struct ScoreAttributeModel: Codable, Hashable {
    let rank: Int
    let comment, userName: String
    let userImageURL: String?
    let date, dateTime: String
    let accepted: Bool
    let repliesCount, likesCount, dislikesCount: Int
    let isLikedByUser, isDisLikedByUser: String

    enum CodingKeys: String, CodingKey {
        case rank, comment
        case userName = "user_name"
        case userImageURL = "user_image_url"
        case date
        case dateTime = "date_time"
        case accepted, repliesCount, likesCount, dislikesCount, isLikedByUser, isDisLikedByUser
    }
}
