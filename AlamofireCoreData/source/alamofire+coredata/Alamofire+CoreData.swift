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

/// A wrapper which encapsulate all the info of the response of a Request 
public struct ResponseInfo {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let error: Error?
}

extension DataResponseSerializer {
    
    /// Createa a new `DataResponseSerializer` which serialize the response in two steps:
    /// - first, it serialize the response using the serializer sent in the parent parameter
    /// - second, take the `Result` returned by the parent and process it using the given transformer
    /// - parameter parent:             The serializer used in the first serialization
    /// - parameter transformer:        The block used for the second serialization
    ///
    /// - returns: a new instance of the serializer
    public init<ParentValue>(
        parent: DataResponseSerializer<ParentValue>,
        transformer: @escaping (ResponseInfo, Result<ParentValue>) -> Result<Value>
        ) {
        self.init(serializeResponse: { request, response, data, error -> Result<Value> in
            let initialResponse = parent.serializeResponse(request, response, data, error)
            return transformer(
                ResponseInfo(request: request, response: response, data: data, error: error),
                initialResponse)
        })
    }
}

extension DataRequest {
    
    /// Initialize a serializer built in two steps:
    /// - The first step serializes the response to get a `JSON`.
    /// - The second step transform the previous `JSON` using the given transformer
    ///
    /// - parameter options:     The JSON serialization reading options. Default is `.allowFragments`
    /// - parameter transformer: The transformer used to proccess the default `JSON`
    ///
    /// - returns: the new serializer
    public static func jsonTransformerSerializer(
        options: JSONSerialization.ReadingOptions = .allowFragments,
        transformer: @escaping ((ResponseInfo, Result<Any>) -> Result<Any>)
        ) -> DataResponseSerializer<Any> {
        
        let parentSerializer = DataRequest.jsonResponseSerializer(options: options)
        return DataResponseSerializer(parent: parentSerializer, transformer: transformer)
    }
    
    /// Creates a response serializer that returns a `Insertable` object result type constructed from the response data using. 
    /// The `Insertable` will be inserted in the given context before being returned.
    ///
    /// - parameter context:        The `NSManagedObjectContext` where the `Insertable` will be inserted
    /// - parameter type:              The `Insertable` type that will be used in the serialization
    /// - parameter jsonSerializer: A `DataResultSerializer` which must return the JSON which will be used to perform the insert. Default is a `DataRequest.jsonResponseSerializer()`
    ///
    /// - returns: An `Insertable` object response serializer.
    public class func responseInsertSerializer<T: Insertable>(
        context: NSManagedObjectContext,
        type: T.Type,
        jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer()
        ) -> DataResponseSerializer<T> {
        
        return DataResponseSerializer(parent: jsonSerializer) { (_, result) -> Result<T> in
            
            guard result.isSuccess else {
                return .failure(result.error!)
            }
            
            do {
                let value: T = try T.insert(from: result.value ?? [:], in: context)
                return .success(value)
            }
            
            catch let error {
                return .failure(error)
            }
        }
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter jsonSerializer:    The se
    /// - parameter context:           A `DataResultSerializer` which must return the JSON which will be used to perform the insert. Default is a `DataRequest.jsonResponseSerializer()`
    /// - parameter type:              The `Insertable` type that will be used in the serialization
    /// - parameter completionHandler: The code to be executed once the request has finished.
    ///
    /// - returns: the request
    @discardableResult
    public func responseInsert<T: Insertable>(
        queue: DispatchQueue? = nil,
        jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
        context: NSManagedObjectContext,
        type: T.Type,
        completionHandler: @escaping (DataResponse<T>) -> Void)
        -> Self
    {
        let serializer = DataRequest.responseInsertSerializer(
            context: context,
            type: T.self,
            jsonSerializer: jsonSerializer
        )
        
        return response(
            queue: queue,
            responseSerializer: serializer,
            completionHandler: completionHandler
        )
    }
}
