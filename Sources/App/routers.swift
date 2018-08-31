import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    try router.register(collection: AcronymsController())
    
    router.get() { req in
        return "Hello, world!"
    }
}
