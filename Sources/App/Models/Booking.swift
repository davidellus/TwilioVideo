//
//  Booking.swift
//  App
//
//  Created by Davide Fastoso on 16/06/2020.
//

import Foundation
import Fluent
import Vapor
final class Booking: Model,Content {
    static let schema = "bookings"
    
    @ID(key: .id) var id: UUID?
//    Visitor and event id
//    Booking are children of both  visitor and event
    @Parent(key: "event_id") var event:Event
//    @Parent(key: "visitor_id") var vistor:Visitor
    
    init() {}
   
    
    init(id:UUID? = nil,eventID:UUID) {
        self.id = id
        self.$event.id = eventID
//        self.$vistor.id = visitorID
        
    }
}
