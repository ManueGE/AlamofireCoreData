//
//  Many.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Foundation
import CoreData
import Groot

/// An `Array` replacement which can just contains `ManyInsertable` instances. 
/// It implements `Insertable` so it can be used to insert-serialize array responses using Alamofire.
/// It can be used in the same way that `Array` exception mutability. Anyway, if you need to access the raw `Array` version of this class, you can use the `array` property.
struct Many<Element: ManyInsertable> {
    /// The array representation of the receiver
    private(set) var array: [Element]
    fileprivate init(_ array: [Element]) {
        self.array = array
    }
}

extension Many: Insertable {
    public static func insert(from json: Any, in context: NSManagedObjectContext) throws -> Many<Element> {
        guard let jsonArray = json as? JSONArray else {
            throw InsertError.invalidJSON(json)
        }
        
        let array = try Element.insertMany(from: jsonArray, in: context) as! [Element]
        return Many(array)
    }
}

// MARK: Array protocols

extension Many: Collection {

    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        return array[bounds]
    }

    var startIndex: Int {
        return array.startIndex
    }
    
    var endIndex: Int {
        return array.endIndex
    }
    
    subscript(position: Int) -> Element {
        return array[position]
    }
    
    func index(after i: Int) -> Int {
        return array.index(after: i)
    }
}

extension Many: CustomReflectable {
    var customMirror: Mirror {
        return array.customMirror
    }
}

extension Many: RandomAccessCollection {
    typealias SubSequence = Array<Element>.SubSequence
    typealias Indices = Array<Element>.Indices
}

extension Many: CustomDebugStringConvertible {
    var debugDescription: String {
        return array.debugDescription
    }
}

extension Many: CustomStringConvertible {
    var description: String {
        return array.description
    }
}
