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

    // MARK: Many
    func testSerializeManyWrapper() {
        
        // given
        let responseArrived = self.expectation(description: "response of async request has arrived")
        var receivedObject: Many<LoginResponse>?
        let expectedJSON: [Any] = [
            [
                "token": "my token",
                "refresh_token": "my refresh token",
                "message": "ok",
                "validity": "18/11/1983",
                "page": 5,
                
                "user": ["id": 10, "name": "manueGE"],
                
                "friends": [
                    ["id": 11, "name": "mila"],
                    ["id": 12, "name": "anaE"],
                ]
            ]
        ]
        
        // when
        stubSuccess(with: expectedJSON)
        Alamofire.request(apiURL)
            .responseInsert(context: persistentContainer.viewContext, type: Many<LoginResponse>.self) { response in
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
            
            XCTAssertEqual(receivedObject?.count, 1, "count does not match")
            
            let response = receivedObject?[0]
            
            XCTAssertEqual(response?.token, "my token", "property does not match")
            XCTAssertEqual(response?.refreshToken, "my refresh token", "property does not match")
            XCTAssertEqual(response?.message, "ok", "property does not match")
            XCTAssertEqual(response?.page, 5, "property does not match")
            
            let date = DateComponents(calendar: .current,
                                      year: 1983,
                                      month: 11,
                                      day: 18).date
            
            XCTAssertEqual(response?.validity, date, "Received data should not be nil")
            
            let user = response?.user
            XCTAssertEqual(user?.id, 10, "Received data should not be nil")
            XCTAssertEqual(user?.name, "manueGE", "property does not match")
            XCTAssertEqual(user?.managedObjectContext, self.persistentContainer.viewContext, "property does not match")
            
            let friends = response?.friends
            XCTAssertEqual(friends?.count, 2, "Received data should not be nil")
            XCTAssertEqual(friends?.first?.id, 11, "Received data should not be nil")
            XCTAssertEqual(friends?.first?.name, "mila", "Received data should not be nil")
            XCTAssertEqual(friends?.first?.managedObjectContext, self.persistentContainer.viewContext, "property does not match")
        }
    }

    // MARK: Nil and without key
    func testSerializeWrapperWithNilValue() {
        
        // given
        let responseArrived = self.expectation(description: "response of async request has arrived")
        var receivedObject: LoginResponse?
        let expectedJSON: [String: Any] = [
            "refresh_token": NSNull(),
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
            XCTAssertNil(receivedObject?.refreshToken, "property should be nil")
        }
    }
    
    func testSerializeWrapperWithMissingKeyNotOverrides() {
        
        // given
        let responseArrived = self.expectation(description: "response of async request has arrived")
        var receivedObject: LoginResponse?
        let expectedJSON: [String: Any] = [
            "token": "my token",
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
            XCTAssertEqual(receivedObject?.token, "my token", "property should be nil")
            XCTAssertEqual(receivedObject?.message, "success", "property should be nil") //success is the default value
        }
    }

}
