//
//  CafeStore.swift
//  CafeFundo
//
//  Created by lackary on 2017/12/27.
//  Copyright © 2017年 LackaryApp. All rights reserved.
//

import Foundation
import UIKit


struct CafeStoreResult: Codable {
    var number: Int
    var data: [Store]
}

struct Store: Codable {
    var name: String
    var uid: String
    var wifi: Double?
    var seat: Double?
    var quiet: Double?
    var tasty: Double?
    var cheap: Double?
    var music: Double?
    var fbId: String?
    var location: Array<Double>?
    var pictureUrl: String?
    var picture: Data?
}
/*
extension Store: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case uid
        case wifi
        case seat
        case quiet
        case tasty
        case cheap
        case music
        case fbId
        case location
        case pictureUrl
        case picture
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        uid = try values.decode(String.self, forKey: .uid)
        wifi = try values.decode(Double.self, forKey: .wifi)
        seat = try values.decode(Double.self, forKey: .seat)
        quiet = try values.decode(Double.self, forKey: .quiet)
        tasty = try values.decode(Double.self, forKey: .tasty)
        cheap = try values.decode(Double.self, forKey: .cheap)
        music = try values.decode(Double.self, forKey: .music)
        fbId = try values.decode(String.self, forKey: .fbId)
        location = try values.decode(Array<Double>.self, forKey: .location)
        pictureUrl = try values.decode(String.self, forKey: .pictureUrl)
        let data = try values.decode(Data.self, forKey: .image)
    }
}
 */

