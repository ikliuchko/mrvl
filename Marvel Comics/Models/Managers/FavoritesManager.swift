//
//  FavoritesManager.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import CoreData
import PromiseKit

protocol FavoritesManager {
    func comics(with id: String, shouldBeAddedToFavorites: Bool) -> Promise<[String]>
    func getFavoritesIDs() -> Promise<[String]>
}

class FavoritesManagerImp: FavoritesManager {
    
    struct Constants {
        static let key = "Favorites"
    }
    
    func getFavoritesIDs() -> Promise<[String]> {
        return .value(UserDefaults.standard.array(forKey: Constants.key) as? [String] ?? [])
    }
    
    
    func comics(with id: String, shouldBeAddedToFavorites: Bool) -> Promise<[String]> {
        return Promise { seal in
            switch shouldBeAddedToFavorites {
            case true:
                guard var favs = UserDefaults.standard.array(forKey: Constants.key) as? [String] else {
                    UserDefaults.standard.set([id], forKey: Constants.key)
                    UserDefaults.standard.synchronize()
                    return seal.fulfill([id])
                }
                guard !favs.contains(id) else { return seal.fulfill(favs) }
                favs.append(id)
                UserDefaults.standard.set(favs, forKey: Constants.key)
                UserDefaults.standard.synchronize()
                return seal.fulfill(favs)
            case false:
                guard let favs = UserDefaults.standard.array(forKey: Constants.key) as? [String] else { return seal.fulfill([]) }
                let filteredFavs = favs.filter { $0 != id }
                UserDefaults.standard.set(filteredFavs, forKey: Constants.key)
                UserDefaults.standard.synchronize()
                return seal.fulfill(filteredFavs)
            }
        }
    }
}

