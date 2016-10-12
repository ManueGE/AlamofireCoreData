//
//  Insertable.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 6/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Foundation
import CoreData
import Groot

/// The errors that can be thrown if
///
/// - invalidJSON: The JSON is invalid and can't be used for the given operation
public enum InsertError: Error {
    case invalidJSON(Any)
}

/// Objects that can be inserted into a `NSManagedObjectContext` from a JSON object
public protocol Insertable {
    
    /// Insert an object of the receiver type in the given context using the received JSON
    ///
    /// - parameter json:    The JSON used to insert the object
    /// - parameter context: The context where the object will be inserted
    ///
    /// - throws: An `InsertError` If the JSON can't be inserted.
    ///
    /// - returns: The inserted object
    static func insert(from json: Any, in context: NSManagedObjectContext) throws -> Self
}

/// Objects that can be bulk-inserted into a `NSManagedObjectContext` from a JSON array
public protocol ManyInsertable {
    
    /// Insert an array object of the receiver type in the given context using the received JSON array
    ///
    /// - parameter json:    The JSON used to insert the objects
    /// - parameter context: The context where the objects will be inserted
    ///
    /// - throws: An `InsertError` If the JSON can't be inserted.
    ///
    /// - returns: The inserted objects. Even tough they are `Any`, they must be the same Type as the receiver
    static func insertMany(from json: Any, in context: NSManagedObjectContext) throws -> [Any]
}

/// When a ManyInsertable is a Insertable too, the default behaviour is return an array built by calling `insert` to any element 
extension ManyInsertable where Self: Insertable {
    public static func insertMany(from json: Any, in context: NSManagedObjectContext) throws -> [Any] {
        guard let array = json as? JSONArray else {
            throw InsertError.invalidJSON(json)
        }
        
        return array.flatMap { try? insert(from: $0, in: context) }
    }
}
