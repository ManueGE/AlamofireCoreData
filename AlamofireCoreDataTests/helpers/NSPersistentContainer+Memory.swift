//
//  NSPersistentContainer+Memory.swift
//  AlamofireCoreData
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    convenience init(inMemoryWithName name: String) {
        let modelURL = Bundle(for: SerializersTests.self).url(forResource: name, withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        
        self.init(name: name, managedObjectModel: model)
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        self.persistentStoreDescriptions = [description]
    }
}
