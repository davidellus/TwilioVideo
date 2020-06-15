import Fluent
import FluentSQLiteDriver
import Vapor
import TwilioPackage

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.twilio.configuration = .environment
    app.databases.use(.sqlite(.file("db2.sqlite")), as: .sqlite)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateEvent())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateEventCategory())
    
    // register routes
    try routes(app)
}
