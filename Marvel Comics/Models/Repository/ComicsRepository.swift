//
//  ComicsRepository.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import PromiseKit
import Swinject
import SwiftyJSON

protocol ComicsRepository {
    func getComics() -> Promise<[Comics]>
}


/// Implementation of Comics Repository
final class ComicsRepositoryImp: ComicsRepository {
    let dataLoader: DataLoader
    
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    convenience required init?(resolver: DIResolver) {
        guard let dLoader = resolver.resolve(DataLoader.self) else {
            return nil
        }
        self.init(dataLoader: dLoader)
    }
    
    
    
    // MARK: - ComicsRepository implementation
    
    func getComics() -> Promise<[Comics]> {
        return dataLoader.getData(for: .getComics)
            .then { json -> Promise<[Comics]> in
                let comics = json["data"]["results"].arrayValue.map { Comics(json: $0) }
                return .value(comics)
        }
    }
}
