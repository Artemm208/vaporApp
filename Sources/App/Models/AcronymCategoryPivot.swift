
import Foundation
import FluentMySQL

final class AcronymCategoryPivot: MySQLUUIDPivot, ModifiablePivot {
    
    var id : UUID?
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    typealias Left = Acronym
    typealias Right = Category
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID

    init(_ acronym: Acronym, _ category: Category) throws {
        self.acronymID = try acronym.requireID()
        self.categoryID = try category.requireID()
    }
}

extension AcronymCategoryPivot: Migration {
    
    static func prepare(
        on connection: MySQLConnection) -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.acronymID, to: \Acronym.id)
                builder.reference(from: \.categoryID, to: \Category.id)
            }
    }
}
