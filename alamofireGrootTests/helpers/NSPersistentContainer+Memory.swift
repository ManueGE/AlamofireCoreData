//
//  NSPersistentContainer+Memory.swift
//  alamofire+groot
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    convenience init(inMemoryWithName name: String) {
        self.init(name: name)
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        self.persistentStoreDescriptions = [description]
    }
}
