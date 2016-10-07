//
//  Insertable+NSManagedObject.swift
//  Alamofire+CoreData.swift
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
