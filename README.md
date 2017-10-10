# AlamofireCoreData

A nice [**Alamofire**](https://github.com/Alamofire/Alamofire) serializer that convert JSON into **CoreData** objects.

With AlamofireCoreData, you will have your JSON mapped and your `NSManagedObject` instances inserted in your context with just a few lines:

````swift
// User is a `NSManagedObject` subclass
Alamofire.request(url)
    .responseInsert(context: context, type: User.self) { response in
        switch response.result {
        case let .success(user):
            // The user object is already inserted in your context!
        case .failure:
            // handle error
        }
}
````

Internally, AlamofireCoreData uses [**Groot**](https://github.com/gonzalezreal/Groot) to serialize JSON into the CoreData objects, so you will need to be familiar with it to use this library. **Groot** is wonderful and it is very well documented so it shouldn't be a problem to get used to it if you are not.

AlamofireCoreData is built around **Alamofire 4.0.x**


## Installing AlamofireCoreData

##### Using CocoaPods

Add the following to your `Podfile`:

````ruby
pod 'AlamofireCoreData'
````

Then run `$ pod install`.

And finally, in the classes where you need **AlamofireCoreData**: 

````swift
import AlamofireCoreData
````

If you don’t have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

--

# Usage

## First steps

The first thing you need to do to user AlamofireCoreData is making your models serializable with Groot. 

Check out [**the Groot project**](https://github.com/gonzalezreal/Groot) to know how. 

## Inserting a single object

Let's supose we have a `NSManagedObject` subclass called `User`. We also have an API which will return a JSON that we want to convert to a instance of `User` and insert it in a given `NSManagedObjectContext`. 

Then, we just have to call the method `responseInsert` of the Alamofire request and pass the context and the type of the object as parameters:

````swift
// User is a `NSManagedObject` subclass
Alamofire.request(url)
    .responseInsert(context: context, type: User.self) { response in
        switch response.result {
        case let .success(user):
            // The user object is already inserted in your context!
        case .failure:
            // handle error
        }
}
````

If the serialization fails, you will have an instance of `InsertError.invalisJSON` in your `.failure(error)`

## Inserting a list of objects

Serializing a list of object is also easy. If your api returns a list of `User`, you can insert them all in your context by using `Many<User>` as the expected type:

````swift
// User is a `NSManagedObject` subclass
Alamofire.request(url)
    .responseInsert(context: context, type: Many<User>.self) { response in
        switch response.result {
        case let .success(users):
            // users is a instance of Many<User>
        case .failure:
            // handle error
        }
}
````

The struct `Many` is just a wrapper around `Array` and it's intended to be used in the same way you would use an `Array`. In any case, you can access to its raw `Array` by calling its propery `array`.

## Transforming your JSON

In some cases, the data we get from the server is not in the right format. It could even happens that we have a XML where one of its fields is the JSON we have to parse (yes, I've found things like those 😅). In order to solve this issues, `responseInsert` has an additional optional parameter that you can use to transform the response into the JSON you need. It is called `jsonSerializer`:

````swift
Alamofire.request(url).responseInsert(
    jsonSerializer: jsonTransformer, 
    context: context, 
    type: User.self) 
````

`jsonTransformer` is just a `Alamofire.DataResponseSerializer<Any>`. You can build your serializer as you want; the only condition is that it must return the JSON which you expect and which can be serialized by **Groot**.

To build this serializer, you could use the Alamofire built-in method:

````swift
public init(serializeResponse: @escaping (URLRequest?, HTTPURLResponse?, Data?, Error?) -> Result<Value>)
````

AlamofireCoreData brings two convenience methods to make easier building this serializers:

- A custom `DataRequestSerializer` initializer

````swift
public init<ParentValue>(
        parent: DataResponseSerializer<ParentValue>,
        transformer: @escaping (ResponseInfo, Result<ParentValue>) -> Result<Value>
        )
````

where the response is processed by the `parent` parameter and then the `Result` is converted by the `transformer` closure.

- A `DataRequest` class method

````swift
public static func jsonTransformerSerializer(
        options: JSONSerialization.ReadingOptions = .allowFragments,
        transformer: @escaping ((ResponseInfo, Result<Any>) -> Result<Any>)
        ) -> DataResponseSerializer<Any>
````

where the response is converted into a JSON and then the `Result` is converted by the `transformer` closure.

Let's see an example of this second method. We have this response:

````json
{
  "success": 1,
  "data": { "id": 1, "name": "manue"}
}
````

We need a serializer which perform two tasks:

- Check the `success` key to know if the request finished succesfully and send an error if not
- Discard the `success` parameter and just send the contents of `data` to serialization.

So, we can create this serializer:

````swift
let jsonTransformer = DataRequest.jsonTransformerSerializer { (responseInfo, result) -> Result<Any> in
    guard result.isSuccess else {
        return result
    }
    
    let json = result.value as! [String: Any]
    let success = json["success"] as! NSNumber
    switch success.boolValue {
    case true:
        return Result.success(json["data"]!)
    default:
        // here we should create or own error and send it
        return Result.failure(anError)
    }
}
````

And call the requests this way:

````swift
Alamofire.request(url).responseInsert(
    jsonSerializer: jsonTransformer, 
    context: context, 
    type: User.self) 
````


## Using Wrapper
Sometimes, our models are not sent alone in the server responses. Instead, they could be wrapped into a bigger json with some additional useful info. For example, let's suppose that we have a response for our login request where we get the user info, the access token, the validity date for the token and a list of friends:

````swift
{
    "info": {
       "token": "THIS_IS_MY_TOKEN",
       "validity": "2020-01-01"
    },
    "user": {
    	"id": "1",
    	"name": "manue",
    },
    "friends": [
        {"id": 2, "name": "Ana"},
        {"id": 3, "name": "Mila"}
    ]
}
```` 

We need to not only inserting the `User` but also the `token`, `validity` and `friends`. To handle this, we have to create a new class or structure and adopt the **`Wrapper`** protocol. For example:

````swift
struct LoginResponse: Wrapper {
    var token: String!
    var validity: Date?
    var user: User!
    var friends: Many<User>!
    
    // required by protocol
    init () {}
    
    // provides info to convert the json
    mutating func map(_ map: Map) {
        token <- map["info.token"]
        validity <- (map["info.validity"], dateTransformer)
        user <- map["user"]
        friends <- map["friends"]
    }
}
````

The map function must use the same syntax as the example shows, using the `<-` operator. Some notes:

- If the var is a `NSManagedObject`, a `Many<NSManagedObject`, another `Wrapper` or a `Many<Wrapper>`, the object is serialized and inserted.
- Note that the collections must be a **`Many` and not an `Array`**. If you would use a `Array<User>` as `friends` type, the objects wouldn't be serialized or inserted. 
- You can add transformers to change the type of the JSON value. In the exaple, the `validity` field of the JSON is a `String` but we need a `Date`. We pass `dateTrasformer` which is just a function that takes an `String` and turn it into a `Date`.

Now, we can call the same method as before but with the `LoginResponse` as the expected type:

````swift
Alamofire.request(loginURL)
    .responseInsert(context: context, type: LoginResponse.self) { response in
        switch response.result {
        case let .success(response):
            // The user and friends are already inserted in your context!
            let user = response.user 
            let friends = response.friends 
            let validity = response.validity 
            let token = response.token
            
        case .failure:
            // handle error
        }
}
````

#### Root keypath
There is a special case when we want to map to an object which is in the root level of the JSON. For example, if we have a `Pagination` object that implements `Wrapper`:

````swift
struct Pagination: Wrapper {
	var total: Int = 0
	var current: Int = 0
	var previous: Int?
	var next: Int?	
	
	// MARK: Wrapper protocol methods
    required init() {}
    
    mutating func map(map: Map) {
        total <- map["total"]
        current <- map["current"]
        previous <- map["previous"]
        next <- map["next"]
   }
}

````
And the response that we have is:

````json
{
	"total": 100,
	"current": 3,
	"previous": 2,
	"next": 4,
	
	"users": [
		{"id": "1", "name": "manue"},
		{"id": "2", "name": "ana"},
		{"id": "3", "name": "lola"}
	]
}
````

Look that the pagination is not under any key, but it is in the root of the JSON. In this case, we can create the next object:

````swift
class UserListResponse: Wrapper {
	var pagination: Pagination!
	var users: Many<User>!
	
	// MARK: Wrapper protocol methods
    required init() {}
    
    func map(map: Map) {
        pagination <- map[.root] // Look that we use `.root` instead of a string
        users <- map["users"]
    }
}

````

--


## Contact

[Manuel García-Estañ Martínez](http://github.com/ManueGE)  
[@manueGE](https://twitter.com/ManueGE)

## License

AlamofireCoreData is available under the [MIT license](LICENSE.md).
