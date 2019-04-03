
import FluentMySQL
import Vapor

struct MakeCategoriesUnique: Migration {

    typealias Database = MySQLDatabase

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Category.self, on: connection) { builder in
            builder.unique(on: \.name)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Category.self, on: connection) { builder in
            builder.deleteUnique(from: \.name)
        }
    }
}
