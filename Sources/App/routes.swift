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
        let room = OutgoingRoom(uniqueName: "Tareq")
        return req.twilio.sendRoom(room)
    }
    app.post("subaccount"){ req-> EventLoopFuture<OutgoingSubAccount> in
        let subaccount = OutgoingSubAccount(friendlyName: "Mio")
        return req.twilio.sendSubAccount(subaccount)
        
    }
    
}

