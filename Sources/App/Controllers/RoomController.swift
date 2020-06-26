////
////  RoomController.swift
////  App
////
////  Created by Davide Fastoso on 25/06/2020.
////
//
//import Foundation
//import Vapor
//import Fluent
//import TwilioPackage
//
//struct RoomController: RouteCollection {
//func boot(routes: RoutesBuilder) throws {
//    
//    let roomRoute = routes.grouped("rooms").grouped(Token.authenticator(),User.guardMiddleware())
//    
//    roomRoute.post(use: createRoom)
//    roomRoute.delete(":roomID",use: delete)
//    }
//    
//    func createRoom(req: Request) throws -> EventLoopFuture<HTTPStatus>{
//        let data = try req.content.decode(EventCreateData.self)
//        let event = try req.content.decode(Event.self)
//        let user = try req.auth.require(User.self)
//        let event1 = Self.event.find(req.parameters.get("id"), on: req.db).unwrap(or: Abort(.notFound))
//        let room = OutgoingRoom(uniqueName: data.title)
//        return req.twilio.sendRoom(room).transform(to: .ok)
//    }
//    
//    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        return Event.find(req.parameters.get("eventID"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .transform(to: .ok)
//    }
//    
//    
//}
