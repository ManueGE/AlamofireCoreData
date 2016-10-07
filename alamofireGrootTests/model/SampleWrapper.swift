//
//  SampleWrapper.swift
//  AlamofireCoreData
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Foundation
import CoreData
@testable import AlamofireCoreData

// Just a sample to test mapper with Insertable as option, normal and force unwrapped
struct SampleWrapper: Wrapper {
    var user: User
    var unwrapUser: User!
    var optionalUser: User?
    
    init() {
        let container = NSPersistentContainer(inMemoryWithName: "model")
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError("Can't create persistent store")
            }
        }
        self.user = User(context: container.viewContext)
    }
    
    mutating func map(_ map: Map) {
        user <- map["user"]
        unwrapUser <- map["unwrap"]
        optionalUser <- map["optional"]
    }
}
