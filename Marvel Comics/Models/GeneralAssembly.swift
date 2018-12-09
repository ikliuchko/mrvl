//
//  GeneralAssembly.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/6/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import Swinject

final class GeneralAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ComicsManager.self) { ComicsManagerImp(resolver: $0)! }.inObjectScope(.container)
        container.register(ComicsRepository.self) { ComicsRepositoryImp(resolver: $0)! }.inObjectScope(.container)
        container.register(SearchManager.self) { SearchManagerImp(resolver: $0)! }.inObjectScope(.container)
        container.register(SearchRepository.self) { SearchRepositoryImp(resolver: $0)! }.inObjectScope(.container)
        container.register(DataLoader.self) { _ in DataLoaderImp() }.inObjectScope(.container)
        container.register(FavoritesManager.self) { _ in FavoritesManagerImp() }.inObjectScope(.container)
    }
}
