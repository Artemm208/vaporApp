
import Vapor
import FluentMySQL
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    var email: String
    var profilePicture: String?
    var twitterURL: String?
    
    init(name: String,
         username: String,
         password: String,
         email: String,
         profilePicture: String? = nil,
         twitterURL: String? = nil) {
        
        self.name = name
        self.username = username
        self.password = password
        self.email = email
        self.profilePicture = profilePicture
        self.twitterURL = twitterURL
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?,
             name: String,
             username: String) {
            
            self.id = id
            self.name = name
            self.username = username
        }
    }
    
    final class PublicV2: Codable {
        var id: UUID?
        var name: String
        var username: String
        var twitterURL: String?
        
        init(id: UUID?,
             name: String,
             username: String,
             twitterURL: String? = nil) {
            
            self.id = id
            self.name = name
            self.username = username
            self.twitterURL = twitterURL
        }
    }
}

extension User.Public: MySQLUUIDModel {}
extension User.Public: Content {}
extension User.PublicV2: MySQLUUIDModel {}
extension User.PublicV2: Content {}

extension User: MySQLUUIDModel {}
extension User: Parameter {}
extension User: Content {}
extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.username)
            builder.field(for: \.password)
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
    
    func convertToPublicV2() -> User.PublicV2 {
        return User.PublicV2(
            id: id,
            name: name,
            username: username,
            twitterURL: twitterURL)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
    
    func convertToPublicV2() -> Future<User.PublicV2> {
        return self.map(to: User.PublicV2.self) { user in
            return user.convertToPublicV2()
        }
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

struct AdminUser: Migration {
    
    typealias Database = MySQLDatabase
    
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("### Failed to create admin user ###")
        }
        
        let user = User(
            name: "Admin",
            username: "admin",
            password: hashedPassword,
            email: "admin@localhost.local")
        
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: MySQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
/* Conform User to PasswordAuthenticatable. This allows Vapor to authenticate users with a username and password when they log in. Since you’ve already implemented the necessary properties for PasswordAuthenticatable in BasicAuthenticatable, there’s nothing to do here. */
extension User: PasswordAuthenticatable {}

/* Conform User to SessionAuthenticatable. This allows the application to save and retrieve your user as part of a session. */
extension User: SessionAuthenticatable {}
