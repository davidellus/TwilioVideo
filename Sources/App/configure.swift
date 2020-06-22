import Fluent
import Vapor
import TwilioPackage
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.twilio.configuration = .environment
   if let databaseURL = Environment.get("DATABASE_URL") {
       app.databases.use(try .postgres(
           url: databaseURL
       ), as: .psql)
   } else {
       app.databases.use(.postgres(
           hostname: Environment.get("DATABASE_HOST") ?? "localhost",
           username: Environment.get("DATABASE_USERNAME") ?? "postgres",
           password: Environment.get("DATABASE_PASSWORD") ?? "password",
           database: Environment.get("DATABASE_NAME") ?? "twiliodb"
       ), as: .psql)
   }

    app.migrations.add(CreateUser())
    app.migrations.add(CreateEvent())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateEventCategory())
    app.migrations.add(CreateBooking())
    app.migrations.add(CreateToken())
    
    if app.environment == .development{
        try app.autoMigrate().wait()
    }
    
    // register routesz
    try routes(app)
}
