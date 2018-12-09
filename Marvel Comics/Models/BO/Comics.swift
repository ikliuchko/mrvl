//
//  Comics.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import SwiftyJSON

class Comics {
    let id: String
    let title: String
    let description: String
    var image: String {
        return (mainImage.isEmpty
            ? mainImage
            : thumbnail)
        .replacingOccurrences(of: "http", with: "https")
    }
    private let mainImage: String
    private let thumbnail: String
    let characters: [String]
    let creators: [String]
    private(set) var isFavorite: Bool = false
    
    init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        description = json["description"].stringValue
        let mainImageData = json["images"].arrayValue.first?.dictionaryValue ?? [:]
        mainImage = (mainImageData["path"]?.stringValue ?? "") + "." + (mainImageData["extension"]?.stringValue ?? "")
        thumbnail = json["thumbnail"]["path"].stringValue + "." + json["thumbnail"]["extension"].stringValue
        characters = json["characters"]["items"].arrayValue.map { $0["name"].stringValue }
        creators = json["creators"]["items"].arrayValue.map { $0["name"].stringValue + "(\($0["role"].stringValue))" }
    }
    
    func setFavorite(_ favorite: Bool) {
        isFavorite = favorite
    }
}
