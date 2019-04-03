import FluentMySQL
import Vapor

struct AddTwitterURLToUser: Migration {
    
    typealias Database = MySQLDatabase
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.twitterURL)
        }
    }
    
    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.deleteField(for: \.twitterURL)
        }
    }
}

