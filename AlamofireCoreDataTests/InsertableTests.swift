//
//  InsertableTests.swift
//  AlamofireCoreData
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import XCTest
import CoreData

class InsertableTests: XCTestCase {

    var persistentContainer: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        persistentContainer = NSPersistentContainer(inMemoryWithName: "model")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError("Can't create persistent store")
            }
        }
    }
    
    override func tearDown() {
        persistentContainer = nil
        super.tearDown()
    }
}
