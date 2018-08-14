import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get() { req in 
        return "коко"
    }
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "!!!Hello, world!"
    }
}
