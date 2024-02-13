//
//  Waifu.swift
//  Waifu
//
//  Created by Andira Yunita on 08/02/24.
//

import Foundation

struct Waifu: Decodable, Identifiable {
    var id = UUID()
    let img: String
    let anime: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case img = "image"
        case anime, name
    }
}
