import Vapor
import Fluent

func routes(_ app: Application) throws {
    let meetupController = MeetupController()
    try app.routes.register(collection: meetupController)
    
    let participantController = ParticipantController()
    try app.routes.register(collection: participantController)
    
    let bulkController = BulkController()
    try app.routes.register(collection: bulkController)
}
