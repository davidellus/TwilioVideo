import Fluent
import Vapor
import TwilioPackage
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.twilio.configuration = .environment
    app.databases.use(.postgres(
           hostname: Environment.get("DATABASE_HOST") ?? "localhost",
           username: Environment.get("DATABASE_USERNAME") ?? "postgres",
           password: Environment.get("DATABASE_PASSWORD") ?? "",
           database: Environment.get("DATABASE_NAME") ?? "twiliodb"
       ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateEvent())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateEventCategory())
    
    // register routes
    try routes(app)
}
