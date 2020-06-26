//
//  EventFromUserController.swift
//  App
//
//  Created by Davide Fastoso on 02/06/2020.
//

import Foundation
import Vapor
import Fluent
import TwilioPackage

struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let eventRoute = routes.grouped("events").grouped(Token.authenticator(),User.guardMiddleware())
        
        eventRoute.post(use: create)
        eventRoute.get(use: index)
        eventRoute.post("new",use: create)
        eventRoute.delete(":eventID",use: delete)
    }
    //Show all events
    func index(req: Request) throws -> EventLoopFuture<[Event]>{
        Event.query(on: req.db).all()
    }
    //Create an Event and link a Room
    func create(req: Request) throws ->EventLoopFuture<Event> {
        let data = try req.content.decode(EventCreateData.self)
        let user = try req.auth.require(User.self)
        let event = try Event(name: data.name,
                              title: data.title,
                              description: data.description,
                              email: data.email,
                              userID: user.requireID()
                                )
        let room = OutgoingRoom(uniqueName: data.title)
        return req.twilio.sendRoom(room, on: req.eventLoop).flatMap {_ in 
            event.create(on: req.db).map{ event }
        }
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
    
    private func checkIfEventExists(_ title: String, req: Request) -> EventLoopFuture<Bool> {
      Event.query(on: req.db)
        .filter(\.$title == title)
        .first()
        .map { $0 != nil }
    }
    
}

struct EventCreateData: Content {
    let title : String
    let name : String
    let description: String?
    let email : String?
    let eventData : Date?
}
