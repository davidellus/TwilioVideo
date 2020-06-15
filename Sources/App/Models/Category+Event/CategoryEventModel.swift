//
//  CategoryEventModel.swift
//  App
//
//  Created by Davide Fastoso on 02/06/2020.
//

import Foundation
import Vapor
import Fluent

final class Category: Model,Content {
    static let schema: String = "categories"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name : String
    
    @Siblings(through: EventCategory.self, from: \.$category, to : \.$event) var events : [Event]
    
    init(){}
    
    init(id: UUID? = nil , name: String){
        self.id = id
        self.name = name
    }
}

final class EventCategory: Model {
    static let schema:  String = "events_categories"
    
    @ID(key: .id) var id: UUID?
    
    //References to the Category
    @Parent(key: "category_id") var category: Category
    
    @Parent(key: "event_id") var event: Event
    
    init(){}
    
    init(categoryID: UUID, eventID: UUID){
        self.$category.id = categoryID
        self.$event.id = eventID
    }
}
