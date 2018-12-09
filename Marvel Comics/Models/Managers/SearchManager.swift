//
//  SearchManager.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import PromiseKit
import Swinject

protocol SearchManager {
    func searchForComics(with title: String) -> Promise<[Comics]>
}

final class SearchManagerImp: SearchManager {
    
    let repository: SearchRepository
    
    
    
    // MARK: - Initializers
    
    init(repository: SearchRepository) {
        self.repository = repository
    }
    
    convenience required init?(resolver: DIResolver) {
        guard let repo = resolver.resolve(SearchRepository.self) else {
            print("Failed to initialize needed dependencies!")
            return nil
        }
        self.init(repository: repo)
    }
    
    
    
    // MARK: - ComicsManager implementation
    
    func searchForComics(with title: String) -> Promise<[Comics]> {
        return repository.searchForComics(with: title)
    }
}
