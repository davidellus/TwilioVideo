//
//  UserMigration.swift
//  App
//
//  Created by Davide Fastoso on 01/06/2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

struct CreateUser: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
        .id()
        .field("name", .string)
        .field("email", .string, .required)
        .field("password_hash", .string, .required)
        .field("user_type", .string, .required)
        .unique(on: "email")
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
