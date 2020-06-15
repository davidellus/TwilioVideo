//
//  CategoryController.swift
//  App
//
//  Created by Davide Fastoso on 02/06/2020.
//

import Foundation
import Vapor
import Fluent

struct CategoryController: RouteCollection{
    func boot(routes: RoutesBuilder) throws {
        let categoryRoutes = routes.grouped("category")
        
        categoryRoutes.post(use: create)
        categoryRoutes.get(use: index)
        categoryRoutes.delete(use: delete)
        categoryRoutes.post(":id","category",":id", use: attachCategoryToEvent)
        
    }
    //Show all category
    func index(req: Request) throws -> EventLoopFuture<[Category]>{
        return Category.query(on: req.db).all()
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<Category>{
        let category = try req.content.decode(Category.self)
        
        return category.save(on: req.db).map{ category }
    }
    
    func delete(_ req: Request) throws-> EventLoopFuture<HTTPStatus>{
        let id = req.parameters.get("id", as: UUID.self)
        
        return Category.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ $0.delete(on: req.db)}
            .transform(to: .ok)
    }
    func attachCategoryToEvent( req: Request) throws -> EventLoopFuture<HTTPStatus>{
           let event = Event.find(req.parameters.get("id"), on: req.db)
               .unwrap(or: Abort(.notFound))
           let category = Category.find(req.parameters.get("id"), on: req.db)
           .unwrap(or: Abort(.notFound))
           
           return event.and(category).flatMap{(event,category) in
               event.$category.attach(category, on: req.db)
           }.transform(to: .ok)
       }
}
