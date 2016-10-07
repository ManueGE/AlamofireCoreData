//
//  Operator.swift
//  Alamofire+CoreData
//
//  Created by Manu on 15/2/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation

infix operator <-

// MARK: Insertable Operator
public func <- <T: Insertable>(left: inout T, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value!
    }
}

public func <- <T: Insertable>( left: inout T?, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

public func <- <T: Insertable>( left: inout T!, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

// MARK: Generic operator
public func <- <T>(left: inout T, right: MapValue?) {
    left <- (right, { $0 })
}

public func <- <T: ExpressibleByNilLiteral> (left: inout T, right: MapValue?) {
    left <- (right, { $0 })
}

// MARK: Generic operator with converter
public func <- <T, R>(left: inout T, right: (mapValue: MapValue?, transformer: (R) -> T)) {
    
    guard let mapValue = right.mapValue else {
        return
    }
    
    let originalValue = mapValue.originalValue as! R
    let transformedValue = right.transformer(originalValue)
    left = transformedValue as T
}

public func <- <T: ExpressibleByNilLiteral, R>(left: inout T, right: (mapValue: MapValue?, transformer: (R) -> T)) {
    
    guard let mapValue = right.mapValue else {
        return
    }
    
    guard let originalValue = mapValue.originalValue else {
        left = nil
        return
    }
    
    let transformedValue = right.transformer(originalValue as! R)
    left = transformedValue as T
}
