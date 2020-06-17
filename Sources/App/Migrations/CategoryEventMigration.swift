//
//  CategoryEventMigration.swift
//  App
//
//  Created by Davide Fastoso on 02/06/2020.
//

import Foundation
import Fluent
import Vapor
import FluentPostgresDriver

struct CreateCategory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories")
        .id()
            .field("name", .string)
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("categories").delete()
    }
}

struct CreateEventCategory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("events_categories")
        .id()
            .field("event_id", .uuid, .required, .references("events","id"))
            .field("category_id", .uuid, .required, .references("categories", "id"))
        .create()
    }
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("events_categories").delete()
    }
}
