//
//  Insertable.swift
//  Alamofire+CoreData.swift
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

/// Objects that can be inserted into a `NSManagedObjectContext`.
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
