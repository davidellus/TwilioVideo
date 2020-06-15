//
//  BookingController.swift
//  App
//
//  Created by Davide Fastoso on 16/06/2020.
//

import Foundation
import Fluent
import Vapor
struct BookingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bookings = routes.grouped("bookings")
        bookings.get(use: index)
        bookings.post(use: create)
        bookings.group(":bookingID") { booking in
            booking.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Booking]> {
        return Booking.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Booking> {
        let booking = try req.content.decode(Booking.self)
        return booking.save(on: req.db).map { booking }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Booking.find(req.parameters.get("bookingID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
