//
//  WrapperTests.swift
//  alamofire+groot
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import XCTest
@testable import AlamofireGroot
import CoreData
import Alamofire

class WrapperTests: InsertableTests {
    
    // MARK: Without serializer
    func testSerializeSingleWrapper() {
        
        // given
        let responseArrived = self.expectation(description: "response of async request has arrived")
        var receivedObject: LoginResponse?
        let expectedJSON: [String: Any] = [
            "token": "my token",
            "refresh_token": "my refresh token",
            "validity": "18/11/1983",
            "page": 5,
            
            "user": ["id": 10, "name": "manueGE"],
            
            "friends": [
                ["id": 11, "name": "mila"],
                ["id": 12, "name": "anaE"],
            ]
        ]
        
        // when
        stubSuccess(with: expectedJSON)
        Alamofire.request(apiURL)
            .responseInsert(context: persistentContainer.viewContext, type: LoginResponse.self) { response in
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
            XCTAssertEqual(receivedObject?.token, "my token", "property does not match")
            XCTAssertEqual(receivedObject?.refreshToken, "my refresh token", "property does not match")
            XCTAssertEqual(receivedObject?.page, 5, "property does not match")
            
            let date = DateComponents(calendar: .current,
                                      year: 1983,
                                      month: 11,
                                      day: 18).date
            
            XCTAssertEqual(receivedObject?.validity, date, "Received data should not be nil")
            
            let user = receivedObject?.user
            XCTAssertEqual(user?.id, 10, "Received data should not be nil")
            XCTAssertEqual(user?.name, "manueGE", "property does not match")
            XCTAssertEqual(user?.managedObjectContext, self.persistentContainer.viewContext, "property does not match")
            
            let friends = receivedObject?.friends
            XCTAssertEqual(friends?.count, 2, "Received data should not be nil")
            XCTAssertEqual(friends?.first?.id, 11, "Received data should not be nil")
            XCTAssertEqual(friends?.first?.name, "mila", "Received data should not be nil")
            XCTAssertEqual(friends?.first?.managedObjectContext, self.persistentContainer.viewContext, "property does not match")
        }
    }
    
    /*
    // MARK: Serializer with transformer
    func testSerializingSingleManagedObjectWithTransformers() {
        // given
        let responseArrived = self.expectation(description: "response of async request arrived")
        var receivedObject: User?
        let expectedJSON: [String: Any] = [
            "status": 1,
            "data": [
                "id": 10,
                "name": "manueGE"
            ]
        ]
        
        // when
        stubSuccess(with: expectedJSON)
        Alamofire.request(apiURL)
            .responseInsert(jsonSerializer: jsonTransformer, context: persistentContainer.viewContext, type: User.self) { response in
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
    
    func testFailSerializingSingleManagedObjectWithTransformers() {
        
        // given
        let responseArrived = self.expectation(description: "response of async request arrived")
        var error: Error?
        let expectedJSON: [String: Any] = [
            "status": 0,
            "error": "error message"
        ]
        
        // when
        stubSuccess(with: expectedJSON)
        Alamofire.request(apiURL)
            .responseInsert(jsonSerializer: jsonTransformer, context: persistentContainer.viewContext, type: User.self) { response in
                switch response.result {
                case .success:
                    XCTFail("The operation shouldn fail")
                case let .failure(e):
                    error = e
                }
                responseArrived.fulfill()
        }
        
        // then
        self.waitForExpectations(timeout: 2) { err in
            XCTAssertNotNil(error, "error should not be nil")
        }
    }
    
    // MARK: Many serializer
    func testSerializeManyObjects() {
        // given
        let responseArrived = self.expectation(description: "response of async request arrived")
        var receivedObject: Many<User>?
        let expectedJSON: [[String: Any]] = [
            [
                "id": 10,
                "name": "manueGE"
            ],
            [
                "id": 14,
                "name": "anaEC"
            ]
        ]
        
        // when
        stubSuccess(with: expectedJSON)
        Alamofire.request(apiURL)
            .responseInsert(context: persistentContainer.viewContext, type: Many<User>.self) { response in
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
            XCTAssertEqual(receivedObject?.count, 2, "property does not match")
            let user = receivedObject?.first!
            XCTAssertEqual(user?.id, 10, "property does not match")
            XCTAssertEqual(user?.name, "manueGE", "property does not match")
            XCTAssertEqual(user?.managedObjectContext, self.persistentContainer.viewContext, "property does not match")
        }
    }
    
    func testFailSerializeManyObjects() {
        
        // given
        let responseArrived = self.expectation(description: "response of async request arrived")
        var error: Error?
        let expectedJSON: [String: Any] = [
            "id": 10,
            "name": "manueGE"
        ]
        
        // when
        stubSuccess(with: expectedJSON)
        Alamofire.request(apiURL)
            .responseInsert(context: persistentContainer.viewContext, type: Many<User>.self) { response in
                switch response.result {
                case .success:
                    XCTFail("The operation shouldn fail")
                case let .failure(e):
                    error = e
                }
                responseArrived.fulfill()
        }
        
        // then
        self.waitForExpectations(timeout: 2) { err in
            XCTAssertNotNil(error, "error should not be nil")
        }
    }
 */
}
