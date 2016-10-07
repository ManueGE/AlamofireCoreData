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

public protocol Insertable {
    static func insert(from json: Any, in context: NSManagedObjectContext) throws -> Self
}
