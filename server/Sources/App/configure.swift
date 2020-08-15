import Vapor
import Fluent
import FluentSQLiteDriver

public func configure(_ app: Application) throws {
    app.databases.use(.sqlite(.file("meetup-db.sqlite")), as: .sqlite)
//    app.databases.use(.sqlite(.memory), as: .sqlite)
    
    app.migrations.add(CreateMeetup())
    app.migrations.add(CreateParticipant())
    app.migrations.add(CreateMeetupParticipant())
    try app.autoMigrate().wait()

    try routes(app)
}
