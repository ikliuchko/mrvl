//
//  DIContainer.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/6/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import Swinject

/**
 Provides a namespace for default DI resolver.
 
 Instances of this class are useless.
 */
final class DIContainer {
    /// Default DI resolver, used in the app.
    static private(set) var defaultResolver: Resolver = {
        do {
            let assemblies: [Assembly] = [GeneralAssembly()]
            let assembler = try Assembler(assemblies: assemblies)
            return assembler.resolver
        }
        catch let err {
            fatalError("Failed to setup dependency injection: \(err)") // App will not work, if DI assembly failed
        }
    }()
}
