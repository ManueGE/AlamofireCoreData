//
//  Insertable+NSManagedObject.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 6/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Foundation
import CoreData
import Groot

extension NSManagedObject: Insertable {
    public static func insert(from json: Any, in context: NSManagedObjectContext) throws -> Self {
        guard let dictionary = json as? JSONDictionary else {
            throw InsertError.invalidJSON(json)
        }
        
        return try object(fromJSONDictionary: dictionary, inContext: context)
    }
}

extension NSManagedObject: ManyInsertable {
    public static func insertMany(from json: Any, in context: NSManagedObjectContext) throws -> [Any] {
        guard let array = json as? JSONArray else {
            throw InsertError.invalidJSON(json)
        }
        
        let entityName = context.entityDescriptionForClass(self).name!
        
        return try objects(withEntityName: entityName,
                           fromJSONArray: array,
                           inContext: context)
    }
}

fileprivate extension NSManagedObjectContext {
    
    /// Return the `NSEntityDescription` for the given type in the receiver `NSManagedObjectContext`.
    /// If the entity can't be found, it will throw a fatalError
    ///
    /// - parameter aClass: The class to match with an entity
    ///
    /// - returns: The `NSEntityDescription`
    func entityDescriptionForClass(_ aClass: NSManagedObject.Type) -> NSEntityDescription {
        
        let entityName = NSStringFromClass(aClass)
        let model = persistentStoreCoordinator!.managedObjectModel
        
        for entityDescription in model.entities {
            
            if entityDescription.managedObjectClassName == entityName {
                return entityDescription
            }
        }
        
        fatalError("Can't found a match for the class \(aClass) in the context \(self)")
    }
}
