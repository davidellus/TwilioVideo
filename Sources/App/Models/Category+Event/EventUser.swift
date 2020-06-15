//
//  EventUser.swift
//  App
//
//  Created by Davide Fastoso on 02/06/2020.
//

import Foundation
import Vapor
import Fluent

final class Event: Model, Content {
    static let schema = "events"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "name") var name: String
    @Field(key: "title") var title:String
    @Field(key: "description") var description:String
    @Timestamp(key: "created_at",on: .create) var createdAt:Date?
    @Field(key: "event_date") var eventDate:Date?
    @Field(key: "capacity") var capacity:Int
    @Field(key: "email") var email: String
    @Parent(key: "user_id") var user: User
    
    @Siblings(through: EventCategory.self, from: \.$event, to: \.$category) var category: [Category]
    
    @Children(for: \.$event) var bookings:[Booking]
    init(){}
    
    init(id: UUID? = nil, name: String, userID: UUID){
        self.id = id
        self.name = name
        self.$user.id = userID
    }
}

