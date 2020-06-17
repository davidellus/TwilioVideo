//
//  EventMigration.swift
//  App
//
//  Created by Davide Fastoso on 02/06/2020.
//

import Foundation
import Fluent
import Vapor
import FluentPostgresDriver

struct CreateEvent: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("events")
        .id()
            .field("name", .string)
            .field("user_id", .uuid, .references("users", "id"))
            .field("title", .string, .required)
            .field("description",.string,.required)
            .field("created_at",.date,.required)
            .field("event_date",.date,.required)
            .field("capacity",.int,.required)
            .field("email",.string,.required)
        .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("events").delete()
    }
}
