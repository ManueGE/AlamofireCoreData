//
//  Wrapper.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 6/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Foundation
import CoreData
import Groot

import Foundation

/// Types that implement this method can insert its properties into a managed object context.
public protocol Wrapper: Insertable, ManyInsertable {
    
    /// Required for instantiate new instances
    init()
    
    /// Override to add the values from the given map to the receiver
    /// Properties must be set using the `<-` operator
    mutating func map(_ map: Map)
}

public extension Wrapper {
    
    public static func insert(from json: Any, in context: NSManagedObjectContext) throws -> Self {
        
        guard let jsonObject = json as? JSONDictionary else {
            throw InsertError.invalidJSON(json)
        }
        
        let map = Map(dictionary: jsonObject, context: context)
        
        var object = Self.init()
        object.map(map)
        
        return object
    }
}


/// The ways of creating a keyPath to represent Dictionaries keyPaths
///
/// - root: it refers to root of the dictionary (the dictionary itself)
/// - path: it refers to the object at the given key path
public enum MapKeyPath {
    case root
    case path(String)
}

/// A struct that store a `[String: Any]` and a `NSManagedObjectContext`. 
/// The values of the dictionary can be inserted into the context by using `serialize` method.
public struct Map {
    
    /// The original dictionary whose values will be serialized
    internal var dictionary: [String: Any]
    
    /// The context that will be used to insert the Insertable objects
    internal var context: NSManagedObjectContext
    
    /// Returns a MapValue with the value at the given keypath. If the receiver doesn't have any value at this keypath it returns nil.
    /// If the value at the keypath is `NSNull` it will return a MapValue with a nil value
    ///
    /// - parameter keyPath: A string key path
    ///
    /// - returns: The MapValue or nil if the keyPath does not exists
    public subscript(keyPath: String) -> MapValue? {
        return self[.path(keyPath)]
    }
    
    /// Returns a MapValue with the value at the given keypath. If the receiver doesn't have any value at this keypath it returns nil. 
    /// If the value at the keypath is `NSNull` it will return a MapValue with a nil value
    ///
    /// - parameter keyPath: The key path
    ///
    /// - returns: The MapValue or nil if the keyPath does not exists
    public subscript(keyPath: MapKeyPath) -> MapValue? {
        
        var originalValue: Any?
        
        switch keyPath {
        case .root:
            originalValue = dictionary
        case .path(let stringKeyPath):
            originalValue = (dictionary as NSDictionary).value(forKeyPath: stringKeyPath)
        }
        
        switch originalValue {
        case nil:
            return nil
        case _ as NSNull:
            return MapValue(originalValue: nil, context: context)
        default:
            return MapValue(originalValue: originalValue, context: context)
        }
    }
}

/// Struct that put together a value from a Map and a `NSManagedObjectContext`.
/// It can serialize the original value to `Insertable` using the `serialize` methods.
public struct MapValue {
    
    /// The original value to serialize
    internal private(set) var originalValue: Any?
    
    /// The context that will be used to insert the `Insertable` objects
    fileprivate var context: NSManagedObjectContext
    
    /**
     Serialize the receiver to a `Insertable` item
     - returns: The serialized and inserted object, nil if there is any error
     */
    internal func serialize<T: Insertable>() -> T? {
        guard let value = originalValue else {
            return nil
        }
        
        return try? T.insert(from: value, in: context)
    }
}
