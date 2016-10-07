//
//  Alamofire+CoreData.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 5/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import Alamofire
import CoreData
import Groot

extension DataResponseSerializer {
    
    public init<ParentValue>(parent: DataResponseSerializer<ParentValue>, serializeResponse: @escaping (Result<ParentValue>) -> Result<Value>) {
        
        self.init(serializeResponse: { request, response, data, error -> Result<Value> in
            let initialResponse = parent.serializeResponse(request, response, data, error)
            return serializeResponse(initialResponse)
        })
    }
}

extension DataRequest {
    
    public static func jsonTransformerSerializer(
        options: JSONSerialization.ReadingOptions = [],
        transformer: @escaping ((Result<Any>) -> Result<Any>)
        ) -> DataResponseSerializer<Any> {
        
        let parentSerializer = DataRequest.jsonResponseSerializer(options: options)
        return DataResponseSerializer(parent: parentSerializer, serializeResponse: transformer)
    }
    
    private class func responseInsertSerializer<T: Insertable>(
        context: NSManagedObjectContext,
        jsonSerializer: DataResponseSerializer<Any>
        ) -> DataResponseSerializer<T> {
        
        return DataResponseSerializer(parent: jsonSerializer) { (result) -> Result<T> in
            
            guard result.isSuccess else {
                return .failure(result.error!)
            }
            
            do {
                let value: T = try T.insert(from: result.value, in: context)
                return .success(value)
            }
            
            catch let error {
                return .failure(error)
            }
        }
    }
    
    @discardableResult
    public func responseInsert<T: Insertable>(
        queue: DispatchQueue? = nil,
        jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
        context: NSManagedObjectContext,
        type: T.Type,
        completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self
    {
        let serializer: DataResponseSerializer<T> = DataRequest.responseInsertSerializer(context: context, jsonSerializer: jsonSerializer)
        return response(
            queue: queue,
            responseSerializer: serializer,
            completionHandler: completionHandler
        )
    }
}

