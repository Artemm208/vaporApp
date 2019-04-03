//
//  ResetPasswordToken.swift
//  App
//
//  Created by Sergey Borovikov on 3/13/19.
//

import FluentMySQL

final class ResetPasswordToken: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension ResetPasswordToken: MySQLUUIDModel {}
extension ResetPasswordToken: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
            return Database.create(self, on: connection) { builder in
                try addProperties(to: builder)
                builder.reference(from: \.userID, to: \User.id)
            }
    }
}

extension ResetPasswordToken {
    var user: Parent<ResetPasswordToken, User> {
        return parent(\.userID)
    }
}
