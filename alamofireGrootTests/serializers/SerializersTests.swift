//
//  SerializersTests.swift
//  alamofire+groot
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import XCTest
@testable import AlamofireGroot
import CoreData
import Alamofire

class SerializersTests: XCTestCase {
    
    let apiURL = "https://api.com/path"
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
    
    func testSerializeSingleManagedObject() {
        
        // given
        let responseArrived = self.expectation(description: "response of async request has arrived")
        var receivedObject: User?
        let expectedJSON: [String: Any] = ["id": 10, "name": "manueGE"]
        
        // when
        stubSuccess(with: expectedJSON)
        Alamofire.request(apiURL)
        .responseInsert(context: persistentContainer.viewContext, type: User.self) { response in
            switch response.result {
            case let .success(user):
                receivedObject = user
            case .failure:
                XCTFail("The operation shouldn't fail")
            }
            responseArrived.fulfill()
        }
        
        // then
        self.waitForExpectations(timeout: 2) { err in
            XCTAssertNotNil(receivedObject, "Received data should not be nil")
            XCTAssertEqual(receivedObject?.id, 10, "property does not match")
            XCTAssertEqual(receivedObject?.name, "manueGE", "property does not match")
            XCTAssertEqual(receivedObject?.managedObjectContext, self.persistentContainer.viewContext, "property does not match")
        }
    }
}
