//
//  ComicsManager.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import PromiseKit
import Swinject

protocol ComicsManager {
    func getComicsList() -> Promise<[Comics]>
}

final class ComicsManagerImp: ComicsManager {
    
    let repository: ComicsRepository
    
    
    
    // MARK: - Initializers
    
    init(repository: ComicsRepository) {
        self.repository = repository
    }
    
    convenience required init?(resolver: DIResolver) {
        guard let repo = resolver.resolve(ComicsRepository.self) else {
                print("Failed to initialize needed dependencies!")
                return nil
        }
        self.init(repository: repo)
    }
    
    
    
    // MARK: - ComicsManager implementation
    
    func getComicsList() -> Promise<[Comics]> {
        return repository.getComics()
    }
}
