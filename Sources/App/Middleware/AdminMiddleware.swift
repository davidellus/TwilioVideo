//
//  AdminMiddleware.swift
//  App
//
//  Created by Davide Fastoso on 12/06/2020.
//

import Foundation
import Vapor

struct ExibithorMiddleware: Middleware{
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let user = try? request.auth.require(User.self),user.userType == .exibithor else {
            return request.eventLoop.makeFailedFuture(Abort(.forbidden))
        }
        return next.respond(to: request)
    }
}

struct AdminMiddleware: Middleware{
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let user = try? request.auth.require(User.self),user.userType == .admin else {
            return request.eventLoop.makeFailedFuture(Abort(.forbidden))
        }
        return next.respond(to: request)
    }
}
