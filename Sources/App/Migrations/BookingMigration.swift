//
//  BookingMigration.swift
//  App
//
//  Created by Davide Fastoso on 16/06/2020.
//

import Foundation
import Fluent
import FluentKit

struct CreateBooking: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("bookings")
            .field("id",.uuid,.identifier(auto: false))
            .field("event_id",.uuid,.references("events", "id"))
//            .field("visitor_id",.uuid,.references("visitors", "id"))
            .unique(on:"id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("bookings").delete()
    }
}
