//
//  EventFromUserController.swift
//  App
//
//  Created by Davide Fastoso on 02/06/2020.
//

import Foundation
import Vapor
import Fluent

struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let eventRoute = routes.grouped("events").grouped(Token.authenticator(),User.guardMiddleware())
        
        eventRoute.post(use: create)
        eventRoute.get("id",use: index)
//        eventRoute.post(use: createEvent)
        eventRoute.delete(":eventID",use: delete)
    }
    //Show all events
    func index(req: Request) throws -> EventLoopFuture<[Event]>{
        Event.query(on: req.db).all()
    }
    //Create ad Event
    func create(req: Request) throws ->EventLoopFuture<Event> {
        let data = try req.content.decode(EventCreateData.self)
        let user = try req.auth.require(User.self)
        let event = try Event(name: data.title, userID: user.requireID())
        
        return event.save(on: req.db).map{ event }
    }
    //Create an Event for a User
    func createEvent(req: Request) throws -> EventLoopFuture<HTTPStatus>{
        let event = Event.find(req.parameters.get("id"), on: req.db).unwrap(or: Abort(.notFound))

        let category = Category.find(req.parameters.get("id"), on: req.db).unwrap(or: Abort(.notFound))

        return event.and(category).flatMap{ (event,category) in
            event.$category.attach(category, on: req.db)
        }.transform(to: .ok)
    }
    //Delete a Event
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Event.find(req.parameters.get("eventID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { event in
                do{
                    let user = try req.auth.require(User.self)
                    guard try user.userType == .exibithor ||
                        user.requireID() == event.$user.id else{
                            throw Abort(.forbidden)
                    }
                    return event.delete(on: req.db).transform(to: .ok)
                }catch{
                    return req.eventLoop.makeFailedFuture(error)
                }
        }
    }
    
}

struct EventCreateData: Content {
    let title : String
}
