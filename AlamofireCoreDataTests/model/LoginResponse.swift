//
//  LoginResponse.swift
//  AlamofireCoreData
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Foundation
@testable import AlamofireCoreData

struct LoginResponse: Wrapper {
    
    var token: String!
    var refreshToken: String?
    var message: String = "success"
    var validity: Date?
    var page: Int = 0
    var user: User!
    var optionalUser: User? = nil
    var friends: Many<User>!
    
    init () {
    }
    
    mutating func map(_ map: Map) {
        token <- map["token"]
        refreshToken <- map["refresh_token"]
        message <- map["message"]
        validity <- (map["validity"], dateTransformer)
        page <- map["page"]
        
        user <- map["user"]
        optionalUser <- map["user"]
        if let optionalUser = optionalUser {
            var anotherUser: User = optionalUser
            anotherUser <- map["user"]
        }

        friends <- map["friends"]
    }
}

func dateTransformer(string: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.date(from: string)
}
