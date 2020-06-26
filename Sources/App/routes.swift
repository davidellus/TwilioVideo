import Fluent
import Vapor
import TwilioPackage
func routes(_ app: Application) throws {
  let userController = UserController()
    let eventController = EventController()
    let categoryController = CategoryController()
    try app.register(collection: userController)
    try app.register(collection: eventController)
    try app.register(collection: categoryController)

    app.post("room"){ req -> EventLoopFuture<OutgoingRoom> in
        let temp = try req.content.decode(OutgoingRoom.self)
        let room = OutgoingRoom(uniqueName: temp.uniqueName)
        return req.twilio.sendRoom(room, on: req.eventLoop)
    }
    app.post("subaccount"){ req-> EventLoopFuture<OutgoingSubAccount> in
        let subaccount = OutgoingSubAccount(friendlyName: "Mio")
        return req.twilio.sendSubAccount(subaccount)
        
    }
    
}
