
import Vapor
import FluentMySQL
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}

extension User.Public: MySQLUUIDModel {}
extension User.Public: Content {}

extension User: MySQLUUIDModel {}
extension User: Content {}
extension User: Parameter {}
extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(
            id: id,
            name: name,
            username: username
        )
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}


// Add password field to User model
struct UserPassword: MySQLUUIDModel { var id: UUID? }

extension UserPassword: MySQLMigration {
    
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: conn) { builder in
            builder.field(for: \.password)
        }
    }
    
    static func revert(on conn: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: conn) { builder in
            builder.deleteField(for: \.password)
        }
    }
}
