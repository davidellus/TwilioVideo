//
//  UserController.swift
//  App
//
//  Created by Davide Fastoso on 01/06/2020.
//

import Foundation
import Vapor
import Fluent


struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("users")
        userRoutes.get(use: indexHandler)
        userRoutes.post("signup",use: createHandler)
        userRoutes.delete(use: delete)
        
                let httpBasicAuthRoutes = userRoutes.grouped(User.authenticator())
                httpBasicAuthRoutes.post("login", use: loginHandler)
                
                // Token.authenticator.middleware() adds Bearer authentication with middleware,
                // Guard middlware ensures a user is logged in
                let tokenAuthRoutes = userRoutes.grouped(Token.authenticator(), User.guardMiddleware())
                tokenAuthRoutes.get("me", use: getMyDetailsHandler)
                
                let adminMiddleware = tokenAuthRoutes.grouped(AdminMiddleware())
                adminMiddleware.delete(":userID", use: deleteHandler)
            }
            
    //Show all user
            func indexHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
                try UserSignup.validate(req)
                let userSignup = try req.content.decode(UserSignup.self)
                return User.query(on: req.db).all()
            }
    
        //Create a USER - OK
            fileprivate func createHandler(req: Request) throws -> EventLoopFuture<NewSession> {
               try UserSignup.validate(req)
            try req.auth.require(User.self)
               let userSignup = try req.content.decode(UserSignup.self)
               let user = try User.create(from: userSignup)
               var token: Token!

               return checkIfUserExists(userSignup.username, req: req).flatMap { exists in
                 guard !exists else {
                   return req.eventLoop.future(error: UserError.usernameTaken)
                 }

                 return user.save(on: req.db)
               }.flatMap {
                 guard let newToken = try? user.createToken(source: .signup) else {
                   return req.eventLoop.future(error: Abort(.internalServerError))
                 }
                 token = newToken
                 return token.save(on: req.db)
               }.flatMapThrowing {
                 NewSession(token: token.value, user: try user.asPublic())
               }
             }
            //Delete a USER - OK
            func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
                return User.find(req.parameters.get("userID"), on: req.db)
                    .unwrap(or: Abort(.notFound))
                    .flatMap { $0.delete(on: req.db) }
                    .transform(to: .ok)
            }
            //Login a User - OCHECK
            func loginHandler(_ req: Request) throws -> EventLoopFuture<NewSession> {
                let user = try req.auth.require(User.self)
                let token = try user.createToken(source: .login)
                     return token.save(on: req.db).flatMapThrowing {
                        NewSession(token: token.value, user: try user.asPublic())}
            }
            
            func getMyDetailsHandler(_ req: Request) throws -> User {
                try req.auth.require(User.self)
            }
    
    func getMyOwnUser(req: Request) throws -> User.Public {
       try req.auth.require(User.self).asPublic()
     }
// - OK
     private func checkIfUserExists(_ username: String, req: Request) -> EventLoopFuture<Bool> {
       User.query(on: req.db)
         .filter(\.$username == username)
         .first()
         .map { $0 != nil }
     }
    
      //GET - ALL USERS WITH EVENTS
        func index(req: Request) throws -> EventLoopFuture<[User]>{
            User.query(on: req.db).with(\.$events).all()
        }
        // DELETE A USER
        func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
            return User.find(req.parameters.get("id"), on: req.db)
                .unwrap(or: Abort(.notFound))
                .flatMap {$0.delete(on: req.db)}
                .transform(to: .ok)
        }
}

struct CreateUserData: Content {
    let name: String
    let email: String
    let password: String
    let userType: UserType
}
