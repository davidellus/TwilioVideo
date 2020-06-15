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
        
        userRoutes.post(use: createHandler)
        userRoutes.get(use: indexHandler)
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
            
            func indexHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
                return User.query(on: req.db).all()
            }
            
            func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
                let userData = try req.content.decode(CreateUserData.self)
                let passwordHash = try Bcrypt.hash(userData.password)
                let user = User(name: userData.name, passwordHash: passwordHash, userType: userData.userType, email: userData.email)
                return user.save(on: req.db).map { user }
            }
            
            func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
                return User.find(req.parameters.get("userID"), on: req.db)
                    .unwrap(or: Abort(.notFound))
                    .flatMap { $0.delete(on: req.db) }
                    .transform(to: .ok)
            }
            
            func loginHandler(_ req: Request) throws -> EventLoopFuture<Token> {
                let user = try req.auth.require(User.self)
                let token = try user.generateToken()
                return token.save(on: req.db).map { token }
            }
            
            func getMyDetailsHandler(_ req: Request) throws -> User {
                try req.auth.require(User.self)
            }
      //GET - ALL USERS
        func index(req: Request) throws -> EventLoopFuture<[User]>{
            User.query(on: req.db).with(\.$events).all()
        }
        //POST _ A USER
        func create(req: Request) throws ->EventLoopFuture<User> {
            let user = try req.content.decode(User.self)
            
            return user.save(on: req.db).map{ user }
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
