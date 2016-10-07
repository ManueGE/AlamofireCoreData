//
//  XCTest+OHHTTPStubs.swift
//  alamofire+groot
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Foundation
import XCTest

import OHHTTPStubs

struct StubError: Error {}

extension XCTest {
    
    private func allowAll(request: URLRequest) -> Bool {
        return true
    }
    
    func stubSuccess(with object: Any) {
        OHHTTPStubs.stubRequests(passingTest: allowAll) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(jsonObject: object, statusCode:200, headers:nil)
        }
    }
    
    func stubError() {
        OHHTTPStubs.stubRequests(passingTest: allowAll) { (_) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(error: StubError())
        }
    }
}
